gopen() {
  local target="${1:-HEAD}"
  local git_root=$(git rev-parse --show-toplevel 2>/dev/null)

  if [ -z "$git_root" ]; then
    echo "Error: Not a git repository."
    return 1
  fi

  local files=""

  # --- MODE 1: Working Directory (git status) ---
  if [ "$target" == "status" ]; then
    echo "--- Working Directory Changes ---"
    # Force color on server
    TERM=xterm-256color git -c color.status=always status --short
    echo "---------------------------------"

    files=$({
      git diff --name-only --diff-filter=d
      git diff --name-only --diff-filter=d --cached
      git ls-files --others --exclude-standard
    } | sort -u)

  # --- MODE 2: Specific Commit (HEAD, etc.) ---
  else
    echo "--- Commit Stats ($target) ---"
    TERM=xterm-256color git --no-pager show --stat --oneline --color=always "$target" 2>/dev/null

    if [ $? -ne 0 ]; then
      echo "Error: Commit '$target' not found."
      return 1
    fi
    echo "------------------------------"

    files=$(git show -m --first-parent --name-only --pretty="format:" "$target")
  fi

  files=$(echo "$files" | sed '/^$/d')

  if [ -z "$files" ]; then
    echo "No selectable files found."
    return 0
  fi

  local git_editor=$(git var GIT_EDITOR)
  local PS3="Select file to open with [ $git_editor ]: "

  local OLD_IFS=$IFS
  IFS=$'\n'

  select filename in $files; do
    if [ -n "$filename" ]; then
      IFS=$OLD_IFS
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

  IFS=$OLD_IFS
}
