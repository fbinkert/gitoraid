gopen() {
  local target="${1:-HEAD}"
  local git_root=$(git rev-parse --show-toplevel)
  local files=""

  # MODE 1: Working Directory (git status)
  if [ "$target" == "status" ]; then
    echo "--- Working Directory Changes ---"
    git status --short
    echo "---------------------------------"

    # Combine 3 lists:
    # 1. Unstaged changes (excluding deleted files)
    # 2. Staged changes (excluding deleted files)
    # 3. Untracked files
    files=$({
      git diff --name-only --diff-filter=d
      git diff --name-only --diff-filter=d --cached
      git ls-files --others --exclude-standard
    } | sort -u)

  # MODE 2: Specific Commit (git show)
  else
    echo "--- Commit Stats ($target) ---"
    # 2> /dev/null suppresses errors if $target isn't a valid commit
    if ! git show --stat --oneline "$target" 2>/dev/null; then
      echo "Error: '$target' is not a valid commit or command."
      return
    fi
    echo "------------------------------"
    files=$(git diff-tree --no-commit-id --name-only -r "$target")
  fi

  if [ -z "$files" ]; then
    echo "No relevant files found."
    return
  fi

  local git_editor=$(git var GIT_EDITOR)
  PS3="Select file to open with [ $git_editor ]: "

  select filename in $files; do
    if [ -n "$filename" ]; then
      local full_path="$git_root/$filename"

      if [ -f "$full_path" ]; then
        $git_editor "$full_path"
        break
      else
        echo "File no longer exists on disk (it might have been deleted)."
      fi
    else
      echo "Invalid selection."
    fi
  done
}
