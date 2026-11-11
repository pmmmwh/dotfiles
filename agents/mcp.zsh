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

  local target file next
  for target in $(jq -r '.targets | keys[]' <<<$manifest); do
    file=$(jq -r --arg t $target '.targets[$t].file' <<<$manifest)
    file=${file/#\~/$HOME}

    next=$(jq --arg t $target --slurpfile current <(if [[ -s $file ]]; then cat $file; else print '{}'; fi) '
      .targets[$t] as $target
      | (.removed[$target.harness] // []) as $removed
      | ((.base // {}) + (.[$target.profile] // {}))
      | with_entries(select((.value.harnesses // [$target.harness]) | index($target.harness)))
      | map_values(
          del(.harnesses)
          | if .url then {type: "http", url: .url} + (del(.url, .type) | with_entries(select(.key == "headers")))
            else {type: "stdio"} + .
            end
          | if $target.typed == false then del(.type) else . end
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
