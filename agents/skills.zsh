#!/usr/bin/env -S zsh -f

# Installs the skills in skills.toml: [base] plus each Claude profile's own section.
#   --dry-run  print what would run
#   --prune    also unlink skills a profile no longer lists

() {
  local SCRIPT_DIR=$(cd $(dirname "${(%):-%x}") && pwd)
  local manifest=$SCRIPT_DIR/skills.toml
  local store=$HOME/.agents/skills
  local dry_run=0 prune=0

  local arg
  for arg; do
    case $arg in
      --dry-run) dry_run=1 ;;
      --prune) prune=1 ;;
      *) print -u2 "Unknown option: $arg"; exit 2 ;;
    esac
  done

  local tool
  for tool in yq jq npx; do
    command -v $tool >/dev/null || { print -u2 "$tool is required"; exit 1 }
  done

  local -A profile_dirs=(
    default $HOME/.claude
    personal $HOME/.claude.personal
  )
  local manifest_json=$(yq -p toml -o json '.' $manifest)

  local profile dir line source link
  local -a skills wanted
  for profile in ${(k)profile_dirs}; do
    dir=$profile_dirs[$profile]
    wanted=()

    print -r -- "==> $profile ($dir)"
    while IFS=$'\t' read -r source line; do
      skills=(${=line})
      wanted+=($skills)
      if (( dry_run )); then
        print -r -- "CLAUDE_CONFIG_DIR=$dir npx skills add $source -g -a claude-code -y -s $skills"
      else
        CLAUDE_CONFIG_DIR=$dir npx -y skills add $source -g -a claude-code -y -s $skills || exit 1
      fi
    done < <(jq -r --arg profile $profile '
      [.base, .[$profile]] | map(to_entries) | add | group_by(.key)[]
      | [.[0].key, (map(.value) | add | join(" "))] | @tsv' <<<$manifest_json)

    # Only links into the store are touched, so skills that a binary installs there stay
    for link in $dir/skills/*(N@); do
      [[ ${link:A} == $store/* ]] || continue
      (( ${wanted[(Ie)${link:t}]} )) && continue
      if (( prune )); then
        (( dry_run )) || rm -- $link
        print -r -- "unlinked ${link:t}"
      else
        print -r -- "not listed: ${link:t} (--prune to unlink)"
      fi
    done
  done
} "$@"
