# git-status

**git-status** is a lightweight Bash script that gives you an improved Git status view.
The tool unifies file status (Modified, Added, Deleted, Renamed) and change magnitude (lines added/removed) and presents them side-by-side.

### Preview

```text
## main...origin/main
 M src/controllers/auth.go | +++++++-------
 A src/utils/helper.js     | ++++++++++
 D src/legacy/script.sh    | -----
 R src/old.css -> new.css  | +++-
 ?? .env.local

```

---

### Requirements

- Bash 4.0+
- Git
