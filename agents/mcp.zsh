#!/usr/bin/env -S zsh -f

# Writes the servers in mcp.toml into each agent's MCP config, keeping the rest of the file.
#   --dry-run  print the servers each target would have instead of writing

() {
  local SCRIPT_DIR=$(cd $(dirname "${(%):-%x}") && pwd)
  local dry_run=0

  local arg
  for arg; do
    case $arg in
      --dry-run) dry_run=1 ;;
      *) print -u2 "Unknown option: $arg"; exit 2 ;;
    esac
  done

  local tool
  for tool in yq jq; do
    command -v $tool >/dev/null || { print -u2 "$tool is required"; exit 1 }
  done

  local manifest=$(yq -p toml -o json '.' $SCRIPT_DIR/mcp.toml)
  local profiles=$(yq -p toml -o json '.' $SCRIPT_DIR/profiles.toml)

  local target file next harness profile
  for target in $(jq -r 'to_entries[] | .key as $h | .value | to_entries[] | select(.value | type == "object" and has("mcp")) | "\($h):\(.key)"' <<<$profiles); do
    harness=${target%%:*} profile=${target#*:}
    file=$(jq -r --arg h $harness --arg p $profile '
      .[$h][$p] as $entry | $entry.mcp
      | if startswith("~") or startswith("/") then . else ($entry.config // $entry.dir) + "/" + . end' <<<$profiles)
    file=${file/#\~/$HOME}

    next=$(jq --arg harness $harness --arg profile $profile --argjson profiles "$profiles" --slurpfile current <(if [[ -s $file ]]; then cat $file; else print '{}'; fi) '
      (.removed[$harness] // []) as $removed
      | ((.base // {}) + (.[$profile] // {}))
      | with_entries(select((.value.harnesses // [$harness]) | index($harness)))
      | map_values(
          del(.harnesses)
          | if .url then {type: "http", url: .url} + (del(.url, .type) | with_entries(select(.key == "headers")))
            else {type: "stdio"} + .
            end
          | if $profiles[$harness].typed == false then del(.type) else . end
        ) as $servers
      | $current[0]
      | .mcpServers = ((.mcpServers // {}) | del(.[$removed[]]) | . + $servers)' <<<$manifest) || exit 1

    print -r -- "==> $target ($file)"
    if (( dry_run )); then
      jq -r '.mcpServers | keys | join(", ")' <<<$next
      continue
    fi
    mkdir -p ${file:h}
    print -r -- $next >$file.tmp && mv $file.tmp $file
  done
} "$@"
