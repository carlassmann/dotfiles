import type { ExtensionAPI, ToolDefinition } from "@earendil-works/pi-coding-agent";
import {
  createBashToolDefinition,
  createEditToolDefinition,
  createFindToolDefinition,
  createGrepToolDefinition,
  createLsToolDefinition,
  createReadToolDefinition,
  createWriteToolDefinition,
} from "@earendil-works/pi-coding-agent";
import { Text, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type ToolCall = {
  id: string;
  name: string;
  args: Record<string, unknown>;
};

type View =
  | { mode: "collapsed" }
  | { mode: "expanded"; indexFromLatest: number };

const toolCallIds: string[] = [];
const toolCalls = new Map<string, ToolCall>();
const activeToolCallIds = new Set<string>();
const rowInvalidators = new Map<string, () => void>();
let view: View = { mode: "collapsed" };
let agentRunning = false;

function value(args: Record<string, unknown>, key: string, fallback = ""): string {
  const result = args[key];
  return typeof result === "string" && result ? result : fallback;
}

function describeToolCall(name: string, args: Record<string, unknown>): string {
  switch (name) {
    case "bash":
      return `$ ${value(args, "command", "…")}`;
    case "read":
      return `Reading ${value(args, "path", "…")}`;
    case "edit":
      return `Editing ${value(args, "path", "…")}`;
    case "write":
      return `Writing ${value(args, "path", "…")}`;
    case "grep":
      return `Searching for ${value(args, "pattern", "…")} in ${value(args, "path", ".")}`;
    case "find":
      return `Finding ${value(args, "pattern", "…")} in ${value(args, "path", ".")}`;
    case "ls":
      return `Listing ${value(args, "path", ".")}`;
    default:
      return name;
  }
}

function latestToolCallId(): string | undefined {
  return toolCallIds.at(-1);
}

function visibleToolCallId(): string | undefined {
  if (view.mode === "collapsed") return latestToolCallId();
  return toolCallIds.at(-1 - view.indexFromLatest);
}

function invalidateRows(): void {
  for (const invalidate of rowInvalidators.values()) invalidate();
}

function resetTurn(): void {
  invalidateRows();
  toolCallIds.length = 0;
  toolCalls.clear();
  activeToolCallIds.clear();
  rowInvalidators.clear();
  view = { mode: "collapsed" };
}

function compactStatus(): string {
  const count = toolCallIds.length;
  if (!agentRunning) return "Done";

  const activeId = [...activeToolCallIds].at(-1);
  if (!activeId) return "Thinking…";

  const activeCall = toolCalls.get(activeId);
  return activeCall ? describeToolCall(activeCall.name, activeCall.args) : "Working…";
}

function countLabel(): string {
  const count = toolCallIds.length;
  return `${count} tool call${count === 1 ? "" : "s"}`;
}

function compactStatusComponent(theme: any) {
  return {
    render(width: number): string[] {
      const right = theme.fg("dim", countLabel());
      const rightWidth = visibleWidth(right);
      const leftWidth = Math.max(0, width - rightWidth - 1);
      const left = truncateToWidth(theme.fg("muted", compactStatus()), leftWidth, "…");
      const spacing = " ".repeat(Math.max(1, width - visibleWidth(left) - rightWidth));
      return [truncateToWidth(`${left}${spacing}${right}`, width, "")];
    },
    invalidate() {},
  };
}

function registerCompactRenderer(pi: ExtensionAPI, definition: ToolDefinition): void {
  const originalRenderCall = definition.renderCall;
  const originalRenderResult = definition.renderResult;

  pi.registerTool({
    ...definition,
    renderShell: "self",
    renderCall(args, theme, context) {
      rowInvalidators.set(context.toolCallId, context.invalidate);
      if (context.toolCallId !== visibleToolCallId()) return new Text("", 0, 0);

      if (view.mode === "expanded" && originalRenderCall) {
        return originalRenderCall(args, theme, {
          ...context,
          expanded: true,
          lastComponent: undefined,
        });
      }

      return compactStatusComponent(theme);
    },
    renderResult(result, options, theme, context) {
      rowInvalidators.set(context.toolCallId, context.invalidate);
      if (context.toolCallId !== visibleToolCallId() || view.mode === "collapsed") {
        return new Text("", 0, 0);
      }

      return originalRenderResult
        ? originalRenderResult(result, { ...options, expanded: true }, theme, {
            ...context,
            expanded: true,
            lastComponent: undefined,
          })
        : new Text(
            result.content
              .filter((item) => item.type === "text")
              .map((item) => item.text)
              .join("\n"),
            0,
            0,
          );
    },
  });
}

export default function compactTools(pi: ExtensionAPI) {
  const cwd = process.cwd();
  const definitions: ToolDefinition[] = [
    createReadToolDefinition(cwd),
    createBashToolDefinition(cwd),
    createEditToolDefinition(cwd),
    createWriteToolDefinition(cwd),
    createGrepToolDefinition(cwd),
    createFindToolDefinition(cwd),
    createLsToolDefinition(cwd),
  ];

  for (const definition of definitions) registerCompactRenderer(pi, definition);

  pi.on("session_start", async (_event, ctx) => {
    resetTurn();
    ctx.ui.setWorkingMessage("Thinking…");
    ctx.ui.setWorkingVisible(true);
  });

  pi.on("agent_start", async (_event, ctx) => {
    resetTurn();
    agentRunning = true;
    ctx.ui.setWorkingMessage("Thinking…");
    ctx.ui.setWorkingVisible(true);
  });

  pi.on("tool_execution_start", async (event, ctx) => {
    if (!toolCalls.has(event.toolCallId)) toolCallIds.push(event.toolCallId);
    toolCalls.set(event.toolCallId, {
      id: event.toolCallId,
      name: event.toolName,
      args: event.args as Record<string, unknown>,
    });
    activeToolCallIds.add(event.toolCallId);
    ctx.ui.setWorkingVisible(view.mode === "expanded");
    invalidateRows();
  });

  pi.on("tool_execution_end", async (event, ctx) => {
    activeToolCallIds.delete(event.toolCallId);
    ctx.ui.setWorkingVisible(view.mode === "expanded");
    invalidateRows();
  });

  pi.on("agent_settled", async (_event, ctx) => {
    agentRunning = false;
    ctx.ui.setWorkingVisible(true);
    invalidateRows();
  });

  pi.registerShortcut("ctrl+o", {
    description: "Expand or cycle tool calls, newest first",
    handler: async (ctx) => {
      if (toolCallIds.length === 0) return;

      if (view.mode === "collapsed") {
        view = { mode: "expanded", indexFromLatest: 0 };
      } else if (view.indexFromLatest < toolCallIds.length - 1) {
        view = { mode: "expanded", indexFromLatest: view.indexFromLatest + 1 };
      } else {
        view = { mode: "collapsed" };
      }

      ctx.ui.setWorkingVisible(view.mode === "expanded" || toolCallIds.length === 0);
      invalidateRows();
    },
  });
}
