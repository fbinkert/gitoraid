# git-status

**git-status** is a lightweight Bash script gives you an improved view of your Git status.

### Preview

```text
## main...origin/main
 M src/controllers/auth.go | +++++++-------
 A src/utils/helper.js     | ++++++++++
 D src/legacy/script.sh    | -----
 R src/old.css -> new.css  | +++-
 ?? .env.local

```

### ✨ Features

- **Unified View:** See file status (Modified, Added, Deleted, Renamed) and change magnitude (lines added/removed) side-by-side.
- **Responsive:** Automatically adjusts the stat graph width based on your terminal window size.
- **Robust:** Handles filenames with spaces, renames, and ANSI color codes correctly.
- **Fast:** Uses Bash built-ins for string parsing to minimize overhead.

---

### 🚀 Installation

#### Option 1: Git Alias (Recommended)

The easiest way to use this is to register it as a git alias.

1. Save the improved script to a location on your machine (e.g., `~/git-overview.sh`).
2. Make it executable:

```bash
chmod +x ~/git-overview.sh

```

3. Add the alias to your git config:

```bash
git config --global alias.overview "!~/git-overview.sh"

```

Now you can simply run:

```bash
git overview

```

#### Option 2: System-wide Command

1. Save the script as `git-overview` (no extension).
2. Move it to a folder in your `$PATH` (e.g., `/usr/local/bin`):

```bash
sudo mv git-overview /usr/local/bin/
sudo chmod +x /usr/local/bin/git-overview

```

3. Because it follows the `git-command` naming convention, Git picks it up automatically:

```bash
git overview

```

---

### 📝 Requirements

- Bash 4.0+
- Git

### 🤝 Contributing

Feel free to fork this project and submit PRs for improvements (e.g., added support for `git status --porcelain` v2 or different stat formatting).
