#!/usr/bin/env -S zsh -f

# Writes the servers in mcp.toml into each agent's MCP config, keeping the rest of it.
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


  # Codex's own `mcp add` starts an OAuth login for every remote server, so its tables are edited in place
  write_codex() {
    local config=$1 servers=$2 removed=$3 file=$1/config.toml
    local names=$(jq -r --argjson removed $removed 'keys + $removed | .[]' <<<$servers)
    if (( dry_run )); then
      print -r -- "mcp_servers: ${(j:, :)${(f)names}}"
      return
    fi
    local kept=$(NAMES=$names awk '
      BEGIN { n = split(ENVIRON["NAMES"], list, "\n"); for (i = 1; i <= n; i++) prefixes["mcp_servers." list[i]] = 1 }
      /^\[/ {
        header = $0; gsub(/^\[+|\]+$| /, "", header); drop = 0
        for (prefix in prefixes) if (header == prefix || index(header, prefix ".") == 1) drop = 1
      }
      !drop { print }' $file 2>/dev/null)
    local rendered=$(jq '{mcp_servers: (map_values(del(.type) | if .headers then (.http_headers = .headers | del(.headers)) else . end))}' <<<$servers | yq -p json -o toml '.')
    mkdir -p $config
    local nl=$'\n'
    print -r -- "${kept:+$kept$nl$nl}$rendered" >$file.tmp && mv $file.tmp $file
  }

  local manifest=$(yq -p toml -o json '.' $SCRIPT_DIR/mcp.toml)
  local profiles=$(yq -p toml -o json '.' $SCRIPT_DIR/profiles.toml)

  local target harness profile format file config servers removed next
  for target in $(jq -r 'to_entries[] | .key as $h | .value | to_entries[] | select(.value | type == "object" and has("mcp")) | "\($h):\(.key)"' <<<$profiles); do
    harness=${target%%:*} profile=${target#*:}
    format=$(jq -r --arg h $harness '.[$h].mcp_format // "mcpServers"' <<<$profiles)
    config=$(jq -r --arg h $harness --arg p $profile '.[$h][$p] | .config // .dir' <<<$profiles)
    config=${config/#\~/$HOME}
    file=$(jq -r --arg h $harness --arg p $profile '
      .[$h][$p].mcp | if startswith("~") or startswith("/") then . else "" end' <<<$profiles)
    file=${file:+${file/#\~/$HOME}}
    file=${file:-$config/$(jq -r --arg h $harness --arg p $profile '.[$h][$p].mcp' <<<$profiles)}

    servers=$(jq --arg harness $harness --arg profile $profile --arg format $format '
      ((.base // {}) + (.[$profile] // {}))
      | with_entries(select((.value.harnesses // [$harness]) | index($harness)))
      | map_values(
          del(.harnesses)
          | if $format == "opencode" then
              if .url then {type: "remote", url: .url} + (with_entries(select(.key == "headers")))
              else {type: "local", command: ([.command] + (.args // []))} + (if .env then {environment: .env} else {} end)
              end
            elif .url then {type: "http", url: .url} + (with_entries(select(.key == "headers")))
            else {type: "stdio"} + .
            end
        )' <<<$manifest)
    removed=$(jq -c --arg harness $harness '.removed[$harness] // []' <<<$manifest)

    print -r -- "==> $target ($file)"
    if [[ $format == codex ]]; then
      write_codex $config $servers $removed
      continue
    fi

    next=$(jq -n --arg format $format --arg typed $(jq -r --arg h $harness '.[$h] | if has("typed") then .typed else true end' <<<$profiles) \
      --argjson servers $servers --argjson removed $removed \
      --slurpfile current <(if [[ -s $file ]]; then cat $file; else print '{}'; fi) '
      def place($path; f): setpath($path; (getpath($path) // {}) | f);
      ($servers | if $typed == "false" then map_values(del(.type)) else . end) as $servers
      | ((if $format == "opencode" then ["mcp", "servers"] else ["mcpServers"] end)) as $path
      | $current[0]
      | (if $format == "opencode" and (has("$schema") | not) then {"$schema": "https://opencode.ai/config.json"} + . else . end)
      | place($path; del(.[$removed[]]) | . + $servers)') || exit 1

    if (( dry_run )); then
      jq -r '(.mcpServers // .mcp.servers) | keys | join(", ")' <<<$next
      continue
    fi
    mkdir -p ${file:h}
    print -r -- $next >$file.tmp && mv $file.tmp $file
  done
} "$@"
