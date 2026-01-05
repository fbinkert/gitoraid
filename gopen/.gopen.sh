#!/bin/bash

gopen() {
  local target="${1:-HEAD}"
  local git_root=$(git rev-parse --show-toplevel 2>/dev/null)

  if [ -z "$git_root" ]; then
    echo "Error: Not a git repository."
    return 1
  fi

  local -a files_list

  # ==========================================
  # MODE 1: STATUS (Working Directory)
  # ==========================================
  if [ "$target" == "status" ]; then
    echo "--- Working Directory Changes ---"

    (
      declare -A diff_stats
      while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*([^|[:space:]]+).*\| ]]; then
          filename="${BASH_REMATCH[1]}"
          [[ -n "$filename" ]] && diff_stats["$filename"]="${line#*|}"
        fi
      done < <(git -c color.diff=always diff --stat=$(($(tput cols) - 3)) HEAD 2>/dev/null | sed '$d')

      git -c color.status=always status -sb | while IFS= read -r line; do
        cleaned_line=$(sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" <<<"$line")
        if [[ "$cleaned_line" =~ ([MADRCU\?]{1,2})[[:space:]]+(.*) ]]; then
          file="${BASH_REMATCH[2]}"
          echo "$line${diff_stats[$file]:+ |${diff_stats[$file]}}"
        else
          echo "$line"
        fi
      done
    )
    echo "---------------------------------"

    while IFS= read -r line; do
      if [[ "$line" == *" -> "* ]]; then
        file="${line#* -> }"
      else
        file="${line:3}"
      fi

      file="${file%\"}"
      file="${file#\"}"

      files_list+=("$file")
    done < <(git status --porcelain)

  # ==========================================
  # MODE 2: RECENT COMMIT
  # ==========================================
  else
    echo "--- Commit Stats ($target) ---"

    git -c color.ui=always --no-pager show --stat --oneline "$target" 2>/dev/null
    if [ $? -ne 0 ]; then
      echo "Error: Commit '$target' not found."
      return 1
    fi
    echo "------------------------------"

    while IFS= read -r file; do
      files_list+=("$file")
    done < <(git show -m --first-parent --name-only --pretty="format:" "$target" | sed '/^$/d')
  fi

  # ==========================================
  # SELECTION MENU
  # ==========================================
  if [ ${#files_list[@]} -eq 0 ]; then
    echo "No selectable files found."
    return 0
  fi

  local git_editor=$(git var GIT_EDITOR)
  PS3="Select file to open with [ $git_editor ]: "

  select filename in "${files_list[@]}"; do
    if [ -n "$filename" ]; then
      local full_path="$git_root/$filename"
      if [ -f "$full_path" ]; then
        $git_editor "$full_path"
        break
      else
        echo "File no longer exists on disk."
      fi
    else
      echo "Invalid selection."
    fi
  done
}
