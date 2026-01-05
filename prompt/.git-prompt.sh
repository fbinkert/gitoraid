#!/bin/bash

function git_prompt() {
  git rev-parse --is-inside-work-tree &>/dev/null || return

  local -A symbols=(
    ["git"]="⎇"
    ["clean"]="✔"
    ["ahead"]="⇡"
    ["behind"]="⇣"
    ["conflicted"]="↯"
    ["stash"]="⚑"
    ["modified"]="✚"
    ["staged"]="●"
    ["renamed"]="⇾"
    ["deleted"]="✖"
    ["untracked"]="…"
    ["no_upstream"]="L"
  )

  # Determine Branch / Tag / Hash
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) ||
    branch=$(git describe --tags --exact-match 2>/dev/null) ||
    branch=$(git rev-parse --short HEAD 2>/dev/null)

  local output="${symbols["git"]} ${branch}"

  # Get Status and Stash counts
  local git_status
  git_status=$(git status --porcelain -b 2>/dev/null)

  # Stash check
  local stash_count=0
  local stash_out
  stash_out=$(git stash list 2>/dev/null)
  [[ -n "$stash_out" ]] && stash_count=$(grep -c ^ <<<"$stash_out")

  # Parse Status Output
  local ahead=0 behind=0
  local conflicted=0 staged=0 modified=0 renamed=0 deleted=0 untracked=0
  local has_upstream=false

  # Read status line by line
  while IFS= read -r line; do
    # --- Header Line (##) ---
    if [[ "$line" == "##"* ]]; then
      if [[ "$line" == *"..."* ]]; then
        has_upstream=true
        if [[ "$line" =~ ahead\ ([0-9]+) ]]; then ahead=${BASH_REMATCH[1]}; fi
        if [[ "$line" =~ behind\ ([0-9]+) ]]; then behind=${BASH_REMATCH[1]}; fi
      else
        if [[ "$line" != *"HEAD (no branch)"* ]]; then
          has_upstream=false
        else
          has_upstream=true
        fi
      fi
      continue
    fi

    local xy=${line:0:2}
    local x=${xy:0:1}
    local y=${xy:1:1}

    # Check Conflicts
    if [[ "$xy" =~ (DD|AU|UD|UA|DU|AA|UU) ]]; then
      ((conflicted++))
      continue
    fi

    # Check Staged
    case "$x" in [MTADRC]) ((staged++)) ;; esac

    # Check Unstaged
    case "$y" in
    M | T) ((modified++)) ;;
    D) ((deleted++)) ;;
    R | C) ((renamed++)) ;;
    esac

    # Check Untracked
    if [[ "$xy" == "??" ]]; then ((untracked++)); fi

  done <<<"$git_status"

  # Build Output String

  # Upstream
  if $has_upstream; then
    [[ "$ahead" -gt 0 ]] && output+="${symbols["ahead"]}${ahead}"
    [[ "$behind" -gt 0 ]] && output+="${symbols["behind"]}${behind}"
  else
    output+=" ${symbols["no_upstream"]}"
  fi

  # Flags
  local flags=()
  [[ "$conflicted" -gt 0 ]] && flags+=("${symbols["conflicted"]}${conflicted}")
  [[ "$stash_count" -gt 0 ]] && flags+=("${symbols["stash"]}${stash_count}")
  [[ "$staged" -gt 0 ]] && flags+=("${symbols["staged"]}${staged}")
  [[ "$modified" -gt 0 ]] && flags+=("${symbols["modified"]}${modified}")
  [[ "$renamed" -gt 0 ]] && flags+=("${symbols["renamed"]}${renamed}")
  [[ "$deleted" -gt 0 ]] && flags+=("${symbols["deleted"]}${deleted}")
  [[ "$untracked" -gt 0 ]] && flags+=("${symbols["untracked"]}")

  if [[ "${#flags[@]}" -eq 0 ]]; then
    output+="|${symbols["clean"]}"
  else
    local joined_flags=""
    for f in "${flags[@]}"; do joined_flags+="$f"; done
    output+="|${joined_flags}"
  fi

  echo "${output}"
}
