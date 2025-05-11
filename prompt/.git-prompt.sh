#!/bin/bash

function git_prompt() {
    # exit if not in git repo
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo ""
        return
    fi

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

    # get branch info
    local branch=$(
        git symbolic-ref --short HEAD 2>/dev/null || # try branch name
        git describe --tags --exact-match 2>/dev/null | # try exact tag
        git rev-parse --short HEAD 2>/dev/null # fallback to commit hash
        )
    local output="${symbols["git"]} ${branch}"
    
    # get upstream status
    local upstream=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)


    if [[ -n $upstream ]]; then
        local counts=$(git rev-list --count --left-right HEAD...@{upstream} 2>/dev/null)
        local ahead=$(cut -f1 <<< "$counts")
        local behind=$(cut -f2 <<< "$counts")
        [[ "$ahead" -gt 0 ]] && output+="${symbols["ahead"]}${ahead}"
        [[ "$behind" -gt 0 ]] && output+="${symbols["behind"]}${behind}"
    else 
        output+=" ${symbols["no_upstream"]}"
    fi

    # get repo status
    local status=$(git status --porcelain 2>/dev/null)
    local flags=()

    # check conflicts count
    local conflicted=$(git diff --name-only --diff-filter=U 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$conflicted" -gt 0 ]]; then
        flags+=("${symbols["conflicted"]}${conflicted}")
    fi

    # check stash count
    local stashed=$(git stash list 2>/dev/null | wc -l)
    [[ "$stashed" -gt 0 ]] && flags+=("${symbols["stash"]}${stashed}")

    # parse status
    local modified=0 staged=0 renamed=0 deleted=0 untracked=0
    while IFS= read -r line; do
        local idx=${line:0:1} # index status
        local work=${line:1:1} # work tree status
       
        # staged
        case "$idx" in
            'M'|'T'|'A'|'D'|'R'|'C') ((staged++)) ;;
        esac

        # unstaged
        case "$work" in
            'M'|'T') ((modified++)) ;;
            'D') ((deleted++)) ;;
            'R'|'C') ((renamed++)) ;;
        esac

        # special cases
        case "${idx}${work}" in
            '??') ((untracked++)) ;;
            '!!') ;;
        esac
    done <<< "$status"

    [[ "$staged" -gt 0 ]] && flags+=("${symbols["staged"]}${staged}")
    [[ "$modified" -gt 0 ]] && flags+=("${symbols["modified"]}${modified}")
    [[ "$renamed" -gt 0 ]] && flags+=("${symbols["renamed"]}${renamed}")
    [[ "$deleted" -gt 0 ]] && flags+=("${symbols["deleted"]}${deleted}")
    [[ "$untracked" -gt 0 ]] && flags+=("${symbols["untracked"]}")

    # build final output
    if [[ "${#flags[@]}" -eq 0 ]]; then
        output+="|${symbols["clean"]}"
    else
        output+="|$(IFS=''; echo "${flags[*]}")"
    fi

    echo "${output}"

}   

