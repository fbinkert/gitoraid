#!/bin/bash

declare -A diff_stats
while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*([^|[:space:]]+).*\| ]]; then
        filename="${BASH_REMATCH[1]}"
        [[ -n "$filename" ]] && diff_stats["$filename"]="${line#*|}"
    fi
done < <( git -c color.diff=always diff --stat=$(($(tput cols) - 3)) HEAD 2>/dev/null | sed '$d')

git -c color.status=always status -sb | while IFS= read -r line; do
    cleaned_line=$(sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" <<< "$line")
    if [[ "$cleaned_line" =~ ([MADRCU\?]{1,2})[[:space:]]+(.*) ]]; then
        file="${BASH_REMATCH[2]}" 
        echo "$line${diff_stats[$file]:+ |${diff_stats[$file]}}"
    else 
        echo "$line"
    fi
done


