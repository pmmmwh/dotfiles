import { spawn } from "node:child_process";

export default function (pi: any) {
  if (!process.env.REX_BLOCK) return;

  // Fires on startup and again when a session is replaced by /new, /resume or a fork
  pi.on("session_start", (_event: unknown, ctx: any) => {
    // RPC mode also reports hasUI, so only the terminal UI is a pane's agent
    if (ctx?.mode !== "tui") return;

    const session_id = ctx?.sessionManager?.getSessionId?.();
    if (!session_id) return;

    // Unset for ephemeral sessions, which cannot be resumed
    const session_file = ctx.sessionManager.getSessionFile?.();
    if (!session_file) return;

    const child = spawn("rex-agent-session", ["pi"], { stdio: ["pipe", "ignore", "ignore"] });
    child.on("error", () => {});
    child.stdin.end(JSON.stringify({ session_id, cwd: process.cwd(), session_file }));
  });
}
