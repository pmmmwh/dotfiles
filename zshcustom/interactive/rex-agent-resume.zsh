#!/usr/bin/env zsh

# Offers to resume the agent that was running in this Rex pane before the server restarted.
# REX_AGENT_RESUME: "auto" (default) runs the command, "prompt" only types it, "off" disables.
# REX_AGENT_ARGS_<CLAUDE|CODEX|OMP|PI|OPENCODE|AGY> add flags to the resume command.

[[ -n $REX_BLOCK ]] || return 0

# Codex hosts sessions in a shared daemon whose hooks run with the REX_BLOCK of whichever pane started it
codex() { command codex --no-daemon "$@" }

# Only the pane's own shell may act; shells started inside it would consume the saved conversation
[[ -n $REX_AGENT_ROOT ]] || export REX_AGENT_ROOT=$$
[[ $REX_AGENT_ROOT == $$ ]] || return 0

_rex_agent_state_file() {
  print -r -- "${XDG_STATE_HOME:-$HOME/.local/state}/rex-agents/${REX_BLOCK//[^A-Za-z0-9._-]/_}.json"
}

_rex_agent_resume() {
  [[ ${REX_AGENT_RESUME:-auto} == off ]] && return
  command -v jq >/dev/null || return

  local -a fields=("${(@f)$(jq -r '.agent, .session_id, .cwd, (.profile // ""), (.session_file // ""), (.env // {} | to_entries[] | "\(.key)=\(.value)")' $1 2>/dev/null)}")
  local agent=$fields[1] session_id=$fields[2] cwd=$fields[3] profile=$fields[4] session_file=$fields[5]
  [[ $session_id =~ '^[A-Za-z0-9._:-]+$' ]] || return
  [[ -z $profile || $profile =~ '^[A-Za-z0-9._-]+$' ]] || return

  local env_prefix kv
  local -A recorded_env
  for kv in ${fields[6,-1]}; do
    [[ ${kv%%=*} =~ '^[A-Z][A-Z0-9_]*$' ]] || return
    env_prefix+="${kv%%=*}=${(q)${kv#*=}} "
    recorded_env[${kv%%=*}]=${kv#*=}
  done
  local config_dir=$recorded_env[CLAUDE_CONFIG_DIR]

  # Flags to resume with, as the shell would parse them, such as REX_AGENT_ARGS_CLAUDE="--model opus"
  [[ $agent =~ '^[a-z]+$' ]] || return
  local extra_var=REX_AGENT_ARGS_${(U)agent} extra
  extra=${(P)extra_var}
  extra=${extra:+ $extra}

  local cmd
  case $agent in
    claude)
      # The transcript only exists once the session has a message, and resuming without one fails
      local -a transcripts=(${config_dir:-$HOME/.claude}/projects/*/$session_id.jsonl(N))
      (( $#transcripts )) || { rm -f -- $1; return }
      # A session handed to the agents daemon outlives a Rex restart, and resuming it would start a second copy.
      # After a reboot the daemon is gone, so its pid must still be alive.
      local -a config_env=(${config_dir:+CLAUDE_CONFIG_DIR=$config_dir})
      local background_pid=$(env $config_env claude agents --json 2>/dev/null |
        jq -r --arg id $session_id 'first(.[] | select(.sessionId == $id and .kind == "background" and .pid != null) | .pid) // empty' 2>/dev/null)
      if [[ -n $background_pid ]] && kill -0 $background_pid 2>/dev/null; then
        cmd="${env_prefix}claude attach ${session_id[1,8]}"
      else
        cmd="${env_prefix}claude --resume $session_id$extra"
      fi
      ;;
    codex) cmd="${env_prefix}codex resume $session_id$extra" ;;
    omp)
      # Like Claude, OMP saves a session only once it has a message. The PI_CONFIG_DIR layout is unverified, so that case skips the check.
      if [[ -n $session_file ]]; then
        [[ -f $session_file ]] || { rm -f -- $1; return }
      elif [[ -z $recorded_env[PI_CONFIG_DIR] ]]; then
        local -a omp_sessions=(${recorded_env[PI_CODING_AGENT_SESSION_DIR]:-${recorded_env[PI_CODING_AGENT_DIR]:-$HOME/.omp/${profile:+profiles/$profile/}agent}/sessions}/*/*_$session_id.jsonl(N))
        (( $#omp_sessions )) || { rm -f -- $1; return }
      fi
      cmd="${env_prefix}omp ${profile:+--profile $profile }--resume $session_id$extra"
      ;;
    pi)
      # pi, too, only saves a session once it has a message
      if [[ -n $session_file ]]; then
        [[ -f $session_file ]] || { rm -f -- $1; return }
      else
        local -a pi_sessions=(${recorded_env[PI_CODING_AGENT_SESSION_DIR]:-${recorded_env[PI_CODING_AGENT_DIR]:-$HOME/.pi/agent}/sessions}/*/*$session_id*.jsonl(N))
        (( $#pi_sessions )) || { rm -f -- $1; return }
      fi
      cmd="${env_prefix}pi --session ${(q)${session_file:-$session_id}}$extra"
      ;;
    opencode)
      # The shared background server keeps the config of whichever profile started it, so another profile needs its own
      cmd="${env_prefix}opencode${recorded_env[OPENCODE_CONFIG_DIR]:+ --standalone} --session $session_id$extra"
      ;;
    agy) cmd="${env_prefix}agy --conversation $session_id$extra" ;;
    *) return ;;
  esac
  [[ -d $cwd && $cwd != $PWD ]] && cmd="cd ${(q)cwd} && $cmd"

  if [[ ${REX_AGENT_RESUME:-auto} == auto ]]; then
    print -s -- $cmd
    eval $cmd
  else
    print -z -- $cmd
  fi
}

# The first prompt is the restored pane. A later one means the agent exited normally,
# whereas a server restart kills the shell too and leaves the record behind.
_rex_agent_precmd() {
  local file=$(_rex_agent_state_file)
  if (( ! ${+_rex_agent_offered} )); then
    typeset -g _rex_agent_offered=1
    [[ -f $file ]] && _rex_agent_resume $file
  else
    rm -f -- $file
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _rex_agent_precmd
