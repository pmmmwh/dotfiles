import { spawn } from "node:child_process";

const POLL_INTERVAL_MS = 500;

export default {
  id: "rex.session",
  setup(api) {
    if (!process.env.REX_BLOCK) return;

    // Subagent sessions are children of the one the pane is showing
    function root(id) {
      const seen = new Set();
      while (typeof id === "string" && !seen.has(id)) {
        seen.add(id);
        const session = api.data.session.get(id);
        if (!session) return;
        if (!session.parentID) return id;
        id = session.parentID;
      }
    }

    let reported;
    function sync() {
      const route = api.ui.router.current();
      if (route.type !== "session") return;
      const session_id = root(route.sessionID);
      if (!session_id || session_id === reported) return;
      reported = session_id;

      const child = spawn("rex-agent-session", ["opencode"], { stdio: ["pipe", "ignore", "ignore"] });
      child.on("error", () => {});
      child.stdin.end(JSON.stringify({ session_id, cwd: process.cwd() }));
    }

    const poll = setInterval(sync, POLL_INTERVAL_MS);
    poll.unref?.();
    return () => clearInterval(poll);
  },
};
