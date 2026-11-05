import { spawn } from "node:child_process";

// OMP sets OMPCODE=1 for the shells it spawns, so a nested OMP is not the pane's agent
const isPaneAgent = !!process.env.REX_BLOCK && process.env.OMPCODE !== "1";

export default function (pi: any) {
  if (!isPaneAgent) return;

  const record = (_event: unknown, ctx: any) => {
    // Subagents run in-process without a UI and emit their own session events
    if (ctx?.hasUI !== true) return;

    const session_id = ctx?.sessionManager?.getSessionId?.();
    if (!session_id) return;

    // A profile has no env var, but its sessions live under profiles/<name>/agent
    const file: string = ctx.sessionManager.getSessionFile?.() ?? "";
    const profile = file.match(/\/profiles\/([^/]+)\/agent\//)?.[1];

    const child = spawn("rex-agent-session", ["omp"], { stdio: ["pipe", "ignore", "ignore"] });
    child.on("error", () => {});
    child.stdin.end(JSON.stringify({ session_id, cwd: process.cwd(), profile, session_file: file || undefined }));
  };

  pi.on("session_start", record);
  pi.on("session_switch", record);
}
