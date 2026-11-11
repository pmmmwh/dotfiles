#!/usr/bin/env -S zsh -f

# Installs the skills in skills.toml: [base] plus each Claude profile's own section,
# then the commands in [binary] and the skills kept in this repo under skills/.
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

  # The CLI links what it installs itself, so this covers skills that something else wrote to the store
  link_into_profile() {
    local target=$2/skills/$1
    [[ -e $target || -L $target ]] && return
    if (( dry_run )); then
      print -r -- "ln -s $store/$1 $target"
    elif [[ -e $store/$1 ]]; then
      mkdir -p $2/skills && ln -s $store/$1 $target
    fi
  }

  local profile dir line source link name command
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
        CLAUDE_CONFIG_DIR=$dir npx -y skills add $source -g -a claude-code -y -s $skills </dev/null || exit 1
      fi
    done < <(jq -r --arg profile $profile '
      [.base, .[$profile]] | map(to_entries) | add | group_by(.key)[]
      | [.[0].key, (map(.value) | add | join(" "))] | @tsv' <<<$manifest_json)

    while IFS=$'\t' read -r name command; do
      wanted+=($name)
      if (( dry_run )); then
        print -r -- "CLAUDE_CONFIG_DIR=$dir $command"
      else
        CLAUDE_CONFIG_DIR=$dir ${(z)command} </dev/null || exit 1
      fi
      link_into_profile $name $dir
    done < <(jq -r '.binary // {} | to_entries[] | [.key, .value] | @tsv' <<<$manifest_json)

    for source in $SCRIPT_DIR/skills/*(N/); do
      name=${source:t}
      wanted+=($name)
      if [[ -e $store/$name && ! -L $store/$name ]]; then
        print -u2 "skipped $name: $store/$name is a directory, not a link"
        continue
      fi
      if (( dry_run )); then
        print -r -- "ln -sfn $source $store/$name"
      else
        mkdir -p $store && ln -sfn $source $store/$name
      fi
      link_into_profile $name $dir
    done

    # Only links into the store are touched
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
