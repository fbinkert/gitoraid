#!/bin/bash

GIT_CONFIG="-c core.quotePath=false -c color.status=always -c color.diff=always"

declare -A diff_stats

while IFS= read -r line; do
  if [[ "$line" =~ ^[[:space:]]*(.*)[[:space:]]+\| ]]; then
    filename="${BASH_REMATCH[1]}"
    filename="${filename%"${filename##*[![:space:]]}"}"

    diff_stats["$filename"]="${line#*|}"
  fi
done < <(git $GIT_CONFIG diff --stat=$(($(tput cols) - 10)) HEAD 2>/dev/null | sed '$d')

git $GIT_CONFIG status -sb | while IFS= read -r line; do

  cleaned_line="${line//$'\e'\[[0-9;]*m/}"

  if [[ "$cleaned_line" =~ ^([[:space:]]*[MADRCU\?]{1,2})[[:space:]]+(.*) ]]; then
    status_code="${BASH_REMATCH[1]}"
    file_part="${BASH_REMATCH[2]}"

    target_file="$file_part"

    if [[ "$file_part" == *" -> "* ]]; then
      target_file="${file_part##* -> }"
    fi

    if [[ -n "${diff_stats["$target_file"]}" ]]; then
      echo "$line |${diff_stats["$target_file"]}"
    else
      echo "$line"
    fi
  else
    echo "$line"
  fi
done
