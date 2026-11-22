# Shared Claude accounts

CLIProxyAPI 8.1.0 runs on the Linux host. Local clients connect through localhost;
remote clients use its Tailscale HTTPS URL. T3 Code reads the pool's quotas through its native
CLIProxyAPI usage source in Settings > Providers. Fill-first routing keeps a
session on one account and fails over when that account becomes unavailable.
Child sessions inherit the account binding.

## Host, Linux

Install Python 3, curl and Tailscale, and sign in to the tailnet. From this repo:

```sh
./install.sh
agent-proxy host
agent-proxy login
```

Repeat `agent-proxy login` for each Claude account. Choose a different account
in the browser each time. The host keeps Claude's existing connection until the
first account is present; successful login then applies the proxy settings.
Start a new Claude session in T3 Code after connecting.

This machine's URL is https://cshed.tail360002.ts.net:8317.
The dashboard is https://cshed.tail360002.ts.net:8317/management.html.
Use the management key from the private profile to sign into the dashboard.
T3 Code already receives this key through setup and stores it in its secret store.

The listener binds to 127.0.0.1:8317. Tailscale Serve exposes HTTPS port 8317
inside the tailnet. API calls and management calls require separate random keys.
Claude and T3 on the host connect directly through localhost, so local sessions
and quota checks keep working during a tailnet outage. Remote clients use HTTPS.
Existing Tailscale Serve routes are preserved. No Funnel or public listener is configured.
Your tailnet ACLs must permit clients to reach this host on port 8317.

The user service starts on login, or at boot if lingering is enabled:

```sh
loginctl enable-linger "$USER"
systemctl --user status cli-proxy-api
journalctl --user -u cli-proxy-api
```

## Client, MacBook or Linux

Install the dotfiles, Python 3 and Tailscale. macOS `./install.sh --full` installs
Python through Homebrew. Sign in to the same tailnet. With SSH access to the host:

```sh
./install.sh
mkdir -p ~/.cli-proxy-api
chmod 700 ~/.cli-proxy-api
scp carl@cshed.tail360002.ts.net:.cli-proxy-api/client.json ~/.cli-proxy-api/host-profile.json
chmod 600 ~/.cli-proxy-api/host-profile.json
agent-proxy client ~/.cli-proxy-api/host-profile.json
rm ~/.cli-proxy-api/host-profile.json
agent-proxy status
```

The private profile carries the API and management keys, but no account OAuth
credentials. Transfer it through SSH or your password manager; never commit it.
A client uses the shared service and does not install or run a local proxy.
If T3 Code was not installed during setup, run `agent-proxy apply` after its
first launch. Start a new Claude session to use the proxy.
The host and tailnet connection must remain available while using it.

## Configuration and rollback

`agents/proxy/config.json` is the host seed, written as valid YAML to
`~/.cli-proxy-api/config.yaml`. Existing host configuration survives repeated
setup. The pinned release is downloaded from GitHub and checked against its
published SHA-256 checksum before installation. To upgrade, change `VERSION` in
`scripts/bin/agent-proxy`, then run `agent-proxy host` and restart the service.

`~/.cli-proxy-api/client.json` holds this machine's role, URL and keys. OAuth
credentials stay in `~/.cli-proxy-api/accounts/` on the host. Generated files are
private and remain outside the repo. Setup detaches `~/.claude/settings.json`
from its tracked symlink before adding secrets. `./install.sh` reapplies the
tracked Claude template with the local proxy settings, without relinking secrets
into the repo. T3's unrelated settings and usage sources are preserved.

```sh
agent-proxy status
agent-proxy apply
agent-proxy disable
```

`disable` removes the Claude connection and T3 usage source on this machine.
It restores previous Claude proxy environment values from the initial backup.
It retains the host service and accounts so other clients keep working.
Run `agent-proxy host` or reimport the profile to reconnect. To shut down the host:

```sh
systemctl --user disable --now cli-proxy-api
tailscale serve --https=8317 off
```

Source and configuration reference:
https://github.com/router-for-me/CLIProxyAPI
https://github.com/router-for-me/CLIProxyAPI/blob/main/config.example.yaml

written with gpt-6.1-sol in Codex
