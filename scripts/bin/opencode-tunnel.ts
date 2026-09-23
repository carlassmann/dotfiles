#!/usr/bin/env node

import { execFileSync } from "node:child_process";
import {
  chmodSync,
  existsSync,
  mkdirSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { homedir } from "node:os";
import path from "node:path";

type Config = {
  allowedEmails: string[];
  hostname: string;
  localPort: number;
  sessionDuration: string;
  tunnelName: string;
};
type AccessApplication = {
  id: string;
  domain?: string;
  destinations?: { uri?: string }[];
};
type Tunnel = { id: string; name: string };

const runtimeDirectory = path.join(homedir(), ".config", "opencode-tunnel");
const tunnelConfigPath = path.join(runtimeDirectory, "cloudflared.yml");
const tunnelLogPath = path.join(runtimeDirectory, "cloudflared.log");
const launchAgentId = "dev.opencode.remote";
const launchAgentPath = path.join(
  homedir(),
  "Library",
  "LaunchAgents",
  `${launchAgentId}.plist`,
);
const usage = `usage: opencode-tunnel [ensure|status|uninstall]

required environment:
  OPENCODE_TUNNEL_HOSTNAME        public hostname
  OPENCODE_TUNNEL_ALLOWED_EMAILS  comma-separated Access allow-list

optional:
  CLOUDFLARE_API_TOKEN            creates/updates Access; otherwise verifies existing Access
  OPENCODE_SERVER_PASSWORD        pins/updates OpenCode basic auth
  OPENCODE_TUNNEL_NAME            default: opencode
  OPENCODE_TUNNEL_PORT            default: 8788
  OPENCODE_TUNNEL_SESSION         default: 24h`;

async function main() {
  const [command = "ensure"] = process.argv.slice(2);
  if (command === "ensure") return ensure(readConfig());
  if (command === "status") return status(readConfig());
  if (command === "uninstall") return uninstallAgent();
  fail(usage);
}

async function ensure(config: Config) {
  requireCommand("opencode");
  requireCommand("cloudflared");
  requirePinnedPassword();
  const tunnel = ensureTunnel(config.tunnelName);

  // Keep the origin offline while Access and DNS change. Failed setup stays private.
  if (
    !process.env.CLOUDFLARE_API_TOKEN &&
    !(await accessProtects(config.hostname))
  )
    fail("CLOUDFLARE_API_TOKEN is required until Cloudflare Access exists");
  stopAgent();
  if (process.env.CLOUDFLARE_API_TOKEN)
    await ensureAccessApplication(config, tunnel);
  else say("Access: reusing verified existing application");
  writeTunnelConfig(config, tunnel);
  cloudflared([
    "tunnel",
    "route",
    "dns",
    "--overwrite-dns",
    config.tunnelName,
    config.hostname,
  ]);
  ensureService(config);
  installAgent();

  if (!(await waitForAccess(config.hostname))) {
    stopAgent();
    fail(
      `Cloudflare Access did not protect https://${config.hostname}; tunnel stopped`,
    );
  }
  say(`ready: https://${config.hostname}`);
}

async function status(config: Config) {
  const service = quietlyRun("opencode", ["service", "status"]);
  say(`service: ${service?.trim() || "not running"}`);
  say(`tunnel: ${agentRunning() ? "running" : "not running"}`);
  const response = await fetch(`https://${config.hostname}`, {
    redirect: "manual",
  }).catch(() => null);
  say(`edge: ${response ? String(response.status) : "unreachable"}`);
}

function readConfig(): Config {
  const hostname = requireEnvironment("OPENCODE_TUNNEL_HOSTNAME")
    .trim()
    .toLowerCase();
  if (!isHostname(hostname)) fail("OPENCODE_TUNNEL_HOSTNAME is invalid");
  const allowedEmails = requireEnvironment("OPENCODE_TUNNEL_ALLOWED_EMAILS")
    .split(",")
    .map((email) => email.trim().toLowerCase())
    .filter(Boolean);
  if (
    allowedEmails.length === 0 ||
    allowedEmails.some((email) => !isEmail(email))
  )
    fail(
      "OPENCODE_TUNNEL_ALLOWED_EMAILS must contain valid comma-separated emails",
    );

  const localPort = Number(process.env.OPENCODE_TUNNEL_PORT ?? "8788");
  if (!Number.isInteger(localPort) || localPort < 1 || localPort > 65535)
    fail("OPENCODE_TUNNEL_PORT must be between 1 and 65535");
  const tunnelName = process.env.OPENCODE_TUNNEL_NAME?.trim() || "opencode";
  if (!/^[a-zA-Z0-9_-]+$/.test(tunnelName))
    fail(
      "OPENCODE_TUNNEL_NAME may contain only letters, numbers, underscores, and dashes",
    );
  const sessionDuration = process.env.OPENCODE_TUNNEL_SESSION?.trim() || "24h";
  if (!/^\d+(?:ns|us|µs|ms|s|m|h)$/.test(sessionDuration))
    fail("OPENCODE_TUNNEL_SESSION must look like 30m or 24h");
  return { allowedEmails, hostname, localPort, sessionDuration, tunnelName };
}

function requirePinnedPassword() {
  const suppliedPassword = process.env.OPENCODE_SERVER_PASSWORD;
  if (suppliedPassword)
    run("opencode", ["service", "set", "password", suppliedPassword]);
  if (!quietlyRun("opencode", ["service", "get", "password"])?.trim())
    fail(
      "OpenCode needs a fixed password; set OPENCODE_SERVER_PASSWORD for the first ensure",
    );
}

function ensureService(config: Config) {
  setServiceValue("hostname", "127.0.0.1");
  setServiceValue("port", String(config.localPort));
  if (!serviceIsListening(config.localPort))
    run("opencode", ["service", "start"]);
  for (
    let attempt = 0;
    attempt < 20 && !serviceIsListening(config.localPort);
    attempt++
  )
    sleep(500);
  if (!serviceIsListening(config.localPort))
    fail(`OpenCode did not start on http://127.0.0.1:${config.localPort}`);
}

function setServiceValue(key: string, value: string) {
  if (quietlyRun("opencode", ["service", "get", key])?.trim() !== value)
    run("opencode", ["service", "set", key, value]);
}

function serviceIsListening(port: number) {
  return quietly("curl", [
    "-sS",
    "--max-time",
    "2",
    "--output",
    "/dev/null",
    `http://127.0.0.1:${port}/`,
  ]);
}

function ensureTunnel(name: string): Tunnel {
  let tunnel = listTunnels().find((candidate) => candidate.name === name);
  if (!tunnel) {
    cloudflared(["tunnel", "create", name]);
    tunnel = listTunnels().find((candidate) => candidate.name === name);
  }
  if (!tunnel) fail(`cloudflared did not create tunnel ${name}`);
  return tunnel;
}

function listTunnels(): Tunnel[] {
  const value: unknown = JSON.parse(
    cloudflared(["tunnel", "list", "--output", "json"]),
  );
  if (!Array.isArray(value))
    fail("unexpected response from cloudflared tunnel list");
  return value.filter(isTunnel);
}

function isTunnel(value: unknown): value is Tunnel {
  if (!value || typeof value !== "object") return false;
  const candidate = value as Record<string, unknown>;
  return typeof candidate.id === "string" && typeof candidate.name === "string";
}

function writeTunnelConfig(config: Config, tunnel: Tunnel) {
  const credentialsPath = path.join(
    homedir(),
    ".cloudflared",
    `${tunnel.id}.json`,
  );
  if (!existsSync(credentialsPath))
    fail(`missing tunnel credentials: ${credentialsPath}`);
  const yaml = `tunnel: ${tunnel.id}
credentials-file: ${credentialsPath}

ingress:
  - hostname: ${config.hostname}
    service: http://127.0.0.1:${config.localPort}
  - service: http_status:404
`;
  mkdirSync(runtimeDirectory, { recursive: true, mode: 0o700 });
  writeFileSync(tunnelConfigPath, yaml, { mode: 0o600 });
  chmodSync(tunnelConfigPath, 0o600);
}

async function ensureAccessApplication(config: Config, tunnel: Tunnel) {
  const apiPath = `/accounts/${tunnelAccountId(tunnel)}/access/apps`;
  const apps = await cloudflareApi<AccessApplication[]>(
    "GET",
    `${apiPath}?per_page=1000`,
  );
  const existing = apps.find(
    (app) =>
      app.domain === config.hostname ||
      app.destinations?.some(
        (destination) => destination.uri === config.hostname,
      ),
  );
  const payload = {
    name: config.tunnelName,
    type: "self_hosted",
    domain: config.hostname,
    destinations: [{ type: "public", uri: config.hostname }],
    session_duration: config.sessionDuration,
    policies: [
      {
        name: `${config.tunnelName}-allowed-emails`,
        decision: "allow",
        precedence: 1,
        include: config.allowedEmails.map((email) => ({ email: { email } })),
      },
    ],
  };
  if (existing)
    await cloudflareApi("PUT", `${apiPath}/${existing.id}`, payload);
  else await cloudflareApi("POST", apiPath, payload);
}

function tunnelAccountId(tunnel: Tunnel): string {
  const credentialsPath = path.join(
    homedir(),
    ".cloudflared",
    `${tunnel.id}.json`,
  );
  const value: unknown = JSON.parse(readFileSync(credentialsPath, "utf8"));
  if (!value || typeof value !== "object")
    fail(`invalid tunnel credentials: ${credentialsPath}`);
  const accountId = (value as Record<string, unknown>).AccountTag;
  if (typeof accountId !== "string" || !accountId)
    fail("tunnel credentials have no AccountTag");
  return accountId;
}

async function cloudflareApi<T = unknown>(
  method: string,
  apiPath: string,
  body?: unknown,
): Promise<T> {
  const response = await fetch(
    `https://api.cloudflare.com/client/v4${apiPath}`,
    {
      method,
      headers: {
        Authorization: `Bearer ${requireEnvironment("CLOUDFLARE_API_TOKEN")}`,
        "Content-Type": "application/json",
      },
      body: body === undefined ? undefined : JSON.stringify(body),
    },
  );
  const value: unknown = await response.json();
  if (!value || typeof value !== "object")
    fail(`Cloudflare API returned ${response.status}`);
  const envelope = value as { errors?: unknown; result?: T; success?: boolean };
  if (!response.ok || envelope.success !== true)
    fail(
      `Cloudflare API ${method} ${apiPath} failed: ${JSON.stringify(envelope.errors)}`,
    );
  return envelope.result as T;
}

async function waitForAccess(hostname: string) {
  for (let attempt = 0; attempt < 20; attempt++) {
    if (await accessProtects(hostname)) return true;
    await new Promise((resolve) => setTimeout(resolve, 1_000));
  }
  return false;
}

async function accessProtects(hostname: string) {
  const response = await fetch(`https://${hostname}`, {
    redirect: "manual",
  }).catch(() => null);
  const location = response?.headers.get("location");
  return Boolean(location && isCloudflareAccessUrl(location));
}

function isCloudflareAccessUrl(location: string) {
  try {
    return new URL(location).hostname.endsWith(".cloudflareaccess.com");
  } catch {
    return false;
  }
}

function installAgent() {
  const cloudflaredPath = requireCommand("cloudflared");
  const plist = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>${launchAgentId}</string>
  <key>ProgramArguments</key>
  <array>
    <string>${escapeXml(cloudflaredPath)}</string>
    <string>tunnel</string>
    <string>--no-autoupdate</string>
    <string>--config</string>
    <string>${escapeXml(tunnelConfigPath)}</string>
    <string>run</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>StandardOutPath</key><string>${escapeXml(tunnelLogPath)}</string>
  <key>StandardErrorPath</key><string>${escapeXml(tunnelLogPath)}</string>
</dict>
</plist>
`;
  mkdirSync(path.dirname(launchAgentPath), { recursive: true });
  writeFileSync(launchAgentPath, plist, { mode: 0o600 });
  stopAgent();
  run("launchctl", ["bootstrap", guiDomain(), launchAgentPath]);
}

function uninstallAgent() {
  stopAgent();
  if (existsSync(launchAgentPath)) rmSync(launchAgentPath);
  say(
    "uninstalled tunnel LaunchAgent; Cloudflare resources and OpenCode service retained",
  );
}

function stopAgent() {
  quietly("launchctl", ["bootout", agentLabel()]);
}
function agentRunning() {
  return quietly("launchctl", ["print", agentLabel()]);
}
function agentLabel() {
  return `${guiDomain()}/${launchAgentId}`;
}
function guiDomain() {
  return `gui/${run("id", ["-u"]).trim()}`;
}
function cloudflared(args: string[]) {
  return run("cloudflared", args);
}

function requireCommand(command: string) {
  const resolved = quietlyRun("which", [command])?.trim();
  if (!resolved) fail(`missing command: ${command}`);
  return resolved;
}

function requireEnvironment(name: string) {
  const value = process.env[name];
  if (!value) fail(`missing ${name}\n\n${usage}`);
  return value;
}

function run(command: string, args: string[] = []) {
  try {
    return execFileSync(command, args, { encoding: "utf8" });
  } catch (error: unknown) {
    const processError = error as { stderr?: string; stdout?: string };
    const output = [processError.stdout, processError.stderr]
      .filter(Boolean)
      .join("\n")
      .trim();
    fail(output || `${command} failed`);
  }
}

function quietlyRun(command: string, args: string[] = []) {
  try {
    return execFileSync(command, args, {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    });
  } catch {
    return null;
  }
}

function quietly(command: string, args: string[] = []) {
  try {
    execFileSync(command, args, { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}

function escapeXml(value: string) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
}
function isHostname(value: string) {
  return (
    value.length <= 253 &&
    value.includes(".") &&
    value
      .split(".")
      .every((label) => /^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/.test(label))
  );
}
function isEmail(value: string) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
}
function sleep(milliseconds: number) {
  Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, milliseconds);
}
function say(message: string) {
  process.stdout.write(`${message}\n`);
}
function fail(message: string): never {
  process.stderr.write(`error: ${message}\n`);
  process.exit(1);
}

await main();
