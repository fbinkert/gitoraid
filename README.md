# Gitoraid

**Gitoraid** is a collection of portable, pure Bash Git utilities designed for **sandboxed environments**, **shared servers**, **containers**, and **legacy systems**.

If you are working on a machine where you:

- Do not have `root` or `sudo` access.
- Cannot install packages (like `zsh`, `starship`, or `oh-my-git`).

...Gitoraid provides a informative Git utilities using only standard Bash features.

## Tools Included

### 1. The Prompt (`git_prompt`)

A fast, shell prompt that displays branch status, upstream details, and file state using standard Unicode symbols.

### 2. The Status (`git-status`)

An enhanced replacement for `git status` that unifies file status (Modified/Added/Deleted) with change magnitude (diff-stat) in a single view.

---

## Usage Guide

### 1. Git Prompt

See [readme.md](prompt/README.md) for instructions on how to configure your prompt.

### 2. Git Status

See [readme.md](status/README.md) for instructions on how to use the enhanced status.

---

## Requirements & Compatibility

- **Shell:** Bash 4.0 or higher.
- **Dependencies:** `git`.

## License

MIT
