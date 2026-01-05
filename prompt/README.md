# Portable Pure Bash Git Prompt

A lightweight, zero-dependency Git prompt designed for **sandboxed environments**, **shared servers**, and **containers** where you do not have root access or cannot install packages (like `zsh`, `starship`, or `oh-my-git`).

It runs entirely in Bash..

### Installation

1. Copy the function code into your `~/.bashrc`.
2. Add the function to your `PS1` variable definition:

```bash
# Example PS1 configuration
# \u = user, \h = host, \w = current directory
export PS1="\u@\h \w \$(git_prompt) $ "

```

3. Reload your configuration:

```bash
source ~/.bashrc

```

### Symbol Legend

| Symbol | Meaning                             |
| ------ | ----------------------------------- |
| **⎇**  | Current Git Branch / Tag / Commit   |
| **✔** | Working tree is clean               |
| **⇡**  | Ahead of upstream (commits to push) |
| **⇣**  | Behind upstream (commits to pull)   |
| **L**  | Local only (no upstream configured) |
| **↯**  | **Conflict** exists                 |
| **⚑**  | Stash exists                        |
| **●**  | Files staged                        |
| **✚**  | Files modified (unstaged)           |
| **…**  | Untracked files                     |

### Compatibility

- Requires **Bash 4.0+**.
