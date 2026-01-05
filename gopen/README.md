# gopen: Git Quick Open

`gopen` is a lightweight Bash function that lets you interactively select and open files changed in your Git history or working directory. It works in sandboxed environments and requires no external dependencies.

## Installation

Add the function code to your `~/.bashrc` and run `source ~/.bashrc`.

## Usage

### 1. Review Recent Work

Open files changed in the most recent commit (`HEAD`).

```bash
gopen
```

### 2. Review Current Changes

Open files you are currently working on (Modified, Staged, or Untracked).

```bash
gopen status
```

### 3. Review Past Commits

Open files from a specific commit hash or reference.

```bash
gopen HEAD~1       # The commit before the last one
gopen a1b2c3d      # A specific commit hash
```

## Configuration

`gopen` automatically uses the editor configured in Git.

**To set VS Code as the default:**

```bash
git config --global core.editor "code --wait"
```

**To set Vim as the default:**

```bash
git config --global core.editor "vim"
```
