# Repo Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `carvalhosauro/skills` the single versioned source of my skills (own + vendored), installable into Claude Code and Cursor with one `./install.sh`, with no duplicates.

**Architecture:** Skills stay in category folders, each a directory with `SKILL.md`. `install.sh` symlinks every top-level skill into `~/.claude/skills` (which both Claude Code and Cursor read), with nested-skill skipping, collision detection, stale-link repair and `--prune`. Vendored skills carry an `UPSTREAM.md`; `scripts/upstream-diff.sh` shows drift. README follows akitaonrails/my-skills.

**Tech Stack:** Bash (no bash-4-only features: no `mapfile`, no associative arrays), git, coreutils `diff`. Tests are plain bash.

**Spec:** `docs/superpowers/specs/2026-09-24-repo-foundation-design.md`

## Global Constraints

- Language: English for README, SKILL.md, scripts, commit messages.
- Layout: keep categories (`code/`, `writing/`, `product/`); no flattening.
- Install paths: `install.sh` + skills.sh only. `.claude-plugin/` is removed.
- Default link target: `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills` only.
- `install.sh` never overwrites or deletes a path that is not a symlink whose link text starts with `$REPO_ROOT/`.
- `UPSTREAM.md` fields are line-oriented `Key: value`: `Source:`, `Path:`, `License:`, `Pinned:`, then a `## Local changes` bullet list.
- `.gitignore` must NOT contain a `*token*` pattern.
- Every commit ends with `Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>`. Conventional Commits subjects.
- Tests never touch the real `$HOME`: every run sets `HOME` and `CLAUDE_CONFIG_DIR` to temp dirs.

## Review Focus

1. Skill directory names containing spaces — links must be created with the exact name (quoting). Test added in Task 1 (case "names with spaces").
2. `CLAUDE_CONFIG_DIR` unset — must fall back to `$HOME/.claude/skills`. Test added in Task 1 (case "default target without CLAUDE_CONFIG_DIR").
3. A skill that moved category leaves a dangling link with the same name — a plain re-run must relink it, not "skip not ours". Test added in Task 1 (case "stale link relinked").
4. `--target` given without a directory — must exit non-zero with a message, not link into `""`. Test added in Task 1 (case "--target without value").
5. `upstream-diff.sh` must be read-only — local skill dir unchanged after a run. Test added in Task 2 (case "read-only").

## File Structure

| Path | Responsibility |
|---|---|
| `install.sh` (rewrite) | Discover skills, validate names, link/copy/uninstall/prune per target. |
| `tests/install.test.sh` (new) | Fixture-based tests for `install.sh`. |
| `scripts/upstream-diff.sh` (new) | Read `UPSTREAM.md`, clone upstream to temp, diff. Read-only. |
| `tests/upstream-diff.test.sh` (new) | Tests using a local `file://` git repo as upstream. |
| `code/git/committing-changes/SKILL.md` (new, moved in) | Own skill, made repo-agnostic. |
| `writing/humanizer/**` (new, vendored) | blader/humanizer package + `UPSTREAM.md`. |
| `skills.sh.json` (modify) | Add Git group; humanizer under Writing. |
| `.gitignore` (modify) | Credential-shaped patterns. |
| `README.md` (rewrite) | Akita-style sections. |
| `agents/`, `.claude-plugin/`, `code/project-docs/` (delete) | Removed per spec. |

---

### Task 1: install.sh rewrite (TDD)

**Files:**
- Create: `tests/install.test.sh`
- Modify (full rewrite): `install.sh`

**Interfaces:**
- Consumes: nothing.
- Produces: CLI `./install.sh [--copy] [--uninstall] [--prune] [--target DIR]... [--help]`. Output lines start with one of `linked`, `copied`, `ok`, `skip`, `pruned`, `removed`, followed by the skill name. Collision message on stderr contains `name collision`. Duplicate-target warning on stderr contains `duplicates`. Exit 1 on collision, no skills, bad args.

- [ ] **Step 1: Write the failing test file**

Create `tests/install.test.sh`:

```bash
#!/usr/bin/env bash
# tests/install.test.sh — exercises install.sh against throwaway fixture repos.
# Never touches the real $HOME: every run gets its own HOME and CLAUDE_CONFIG_DIR.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
INSTALL="$HERE/../install.sh"
fails=0

# new_fixture <skill-path>... → prints root of a fresh fixture (root/repo, root/home)
new_fixture() {
  local root s
  root="$(cd "$(mktemp -d)" && pwd -P)"
  mkdir -p "$root/repo" "$root/home"
  cp "$INSTALL" "$root/repo/install.sh"
  for s in "$@"; do
    mkdir -p "$root/repo/$s"
    printf -- '---\nname: %s\n---\n' "$(basename "$s")" > "$root/repo/$s/SKILL.md"
  done
  echo "$root"
}

# run <root> [args...] → runs the fixture's install.sh with an isolated HOME
run() {
  local root="$1"; shift
  HOME="$root/home" CLAUDE_CONFIG_DIR="$root/home/.claude" bash "$root/repo/install.sh" "$@"
}

check() {
  if [ "$2" -eq 0 ]; then echo "PASS  $1"; else echo "FAIL  $1"; fails=$((fails + 1)); fi
}

# 1. fresh install links every skill
r="$(new_fixture code/a writing/b)"
run "$r" >/dev/null
[ "$(readlink "$r/home/.claude/skills/a")" = "$r/repo/code/a" ] \
  && [ "$(readlink "$r/home/.claude/skills/b")" = "$r/repo/writing/b" ]
check "fresh install links every skill" $?

# 2. re-run is a no-op
out="$(run "$r")"
grep -q '^ok  *a' <<<"$out" && ! grep -q '^linked' <<<"$out"
check "re-run is a no-op" $?

# 3. nested SKILL.md is not linked
r="$(new_fixture code/pkg code/pkg/sub)"
run "$r" >/dev/null
[ -L "$r/home/.claude/skills/pkg" ] && [ ! -e "$r/home/.claude/skills/sub" ]
check "nested SKILL.md not linked" $?

# 4. name collision aborts before writing
r="$(new_fixture code/x writing/x)"
run "$r" >/dev/null 2>"$r/err"; rc=$?
[ "$rc" -eq 1 ] && [ ! -e "$r/home/.claude/skills" ] && grep -q 'name collision' "$r/err"
check "name collision exits 1 and creates nothing" $?

# 5. foreign existing dir is skipped, not overwritten
r="$(new_fixture code/a)"
mkdir -p "$r/home/.claude/skills/a"; echo keep > "$r/home/.claude/skills/a/file"
out="$(run "$r")"
[ ! -L "$r/home/.claude/skills/a" ] && [ -f "$r/home/.claude/skills/a/file" ] && grep -q '^skip  *a' <<<"$out"
check "foreign dir skipped" $?

# 6. --prune removes dangling repo links, keeps foreign dangling links
r="$(new_fixture code/a)"
mkdir -p "$r/home/.claude/skills"
ln -s "$r/repo/code/gone" "$r/home/.claude/skills/gone"
ln -s "/nonexistent/elsewhere" "$r/home/.claude/skills/foreign"
run "$r" --prune >/dev/null
[ ! -L "$r/home/.claude/skills/gone" ] && [ -L "$r/home/.claude/skills/foreign" ] && [ -L "$r/home/.claude/skills/a" ]
check "--prune removes only dangling repo links" $?

# 7. stale link to a moved skill is relinked on a plain run
r="$(new_fixture code/a)"
mkdir -p "$r/home/.claude/skills"
ln -s "$r/repo/old-category/a" "$r/home/.claude/skills/a"
run "$r" >/dev/null
[ "$(readlink "$r/home/.claude/skills/a")" = "$r/repo/code/a" ]
check "stale link relinked" $?

# 8. --uninstall removes only our links
r="$(new_fixture code/a)"
run "$r" >/dev/null
ln -s /tmp "$r/home/.claude/skills/other"
run "$r" --uninstall >/dev/null
[ ! -e "$r/home/.claude/skills/a" ] && [ ! -L "$r/home/.claude/skills/a" ] && [ -L "$r/home/.claude/skills/other" ]
check "--uninstall removes only our links" $?

# 9. --target links into the extra dir and warns for ~/.agents/skills
r="$(new_fixture code/a)"
run "$r" --target "$r/home/.agents/skills" >/dev/null 2>"$r/err"
[ -L "$r/home/.claude/skills/a" ] && [ -L "$r/home/.agents/skills/a" ] && grep -q 'duplicates' "$r/err"
check "--target links extra dir and warns" $?

# 10. names with spaces
r="$(new_fixture "code/my skill")"
run "$r" >/dev/null
[ "$(readlink "$r/home/.claude/skills/my skill")" = "$r/repo/code/my skill" ]
check "names with spaces" $?

# 11. default target without CLAUDE_CONFIG_DIR
r="$(new_fixture code/a)"
env -u CLAUDE_CONFIG_DIR HOME="$r/home" bash "$r/repo/install.sh" >/dev/null
[ -L "$r/home/.claude/skills/a" ]
check "default target without CLAUDE_CONFIG_DIR" $?

# 12. --target without value
r="$(new_fixture code/a)"
run "$r" --target >/dev/null 2>&1; rc=$?
[ "$rc" -ne 0 ] && [ ! -e "$r/home/.claude/skills" ]
check "--target without value" $?

# 13. no skills found
r="$(new_fixture)"
run "$r" >/dev/null 2>&1; rc=$?
[ "$rc" -eq 1 ]
check "no skills exits 1" $?

echo
[ "$fails" -eq 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
```

- [ ] **Step 2: Run tests against the current script, verify they fail**

Run: `bash tests/install.test.sh`
Expected: exits 1 with `5 failed` — cases 3, 4, 6, 7, 9 print `FAIL` (current script links nested skills, has no collision check, no `--prune`, no stale relink, no `--target`). The other cases already pass (case 12 passes because the old script rejects `--target` as unknown).

- [ ] **Step 3: Rewrite `install.sh`**

Replace the whole file with:

```bash
#!/usr/bin/env bash
#
# install.sh — link this repo's skills into your agents' skills directories.
#
# Default target: ${CLAUDE_CONFIG_DIR:-~/.claude}/skills. Claude Code reads it,
# and Cursor reads it too (compatibility dir), so one link serves both.
# Skills are SYMLINKED, so `git pull` updates everything you installed.
#
# Usage:
#   ./install.sh                  link every skill into the default target
#   ./install.sh --target DIR     also link into DIR (repeatable), e.g. ~/.codex/skills
#   ./install.sh --prune          after installing, drop dangling links into this repo
#   ./install.sh --copy           copy instead of symlink (snapshot, won't track the repo)
#   ./install.sh --uninstall      remove every link into this repo from each target
#   ./install.sh --help
#
# Never overwrites or deletes anything that is not a symlink into this repo.

set -euo pipefail
shopt -s nullglob

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TARGETS=("${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills")
MODE="link"      # link | copy
ACTION="install" # install | uninstall
PRUNE=0

usage() { awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; next } NR > 1 { exit }' "${BASH_SOURCE[0]}"; }

while [ $# -gt 0 ]; do
  case "$1" in
    --copy)      MODE="copy" ;;
    --uninstall) ACTION="uninstall" ;;
    --prune)     PRUNE=1 ;;
    --target)
      if [ $# -lt 2 ] || [ -z "$2" ]; then echo "--target needs a directory" >&2; exit 1; fi
      TARGETS+=("$2"); shift ;;
    -h|--help)   usage; exit 0 ;;
    *) echo "unknown argument: $1 (try --help)" >&2; exit 1 ;;
  esac
  shift
done

# True when $1 is a symlink whose link text points inside this repo.
points_into_repo() {
  [ -L "$1" ] || return 1
  case "$(readlink "$1")" in "$REPO_ROOT"/*) return 0 ;; esac
  return 1
}

# --- Uninstall: remove our links from every target, nothing else ---
if [ "$ACTION" = "uninstall" ]; then
  for target in "${TARGETS[@]}"; do
    removed=0
    for entry in "$target"/*; do
      if points_into_repo "$entry"; then
        rm "$entry"; echo "removed  $(basename "$entry")"; removed=$((removed + 1))
      fi
    done
    echo "$target: removed $removed"
  done
  exit 0
fi

# --- Discovery: every dir with SKILL.md, skipping skills nested in another skill ---
is_nested() {
  local d
  d="$(dirname "$1")"
  while [ "$d" != "$REPO_ROOT" ] && [ "$d" != "/" ]; do
    [ -f "$d/SKILL.md" ] && return 0
    d="$(dirname "$d")"
  done
  return 1
}

SKILLS=()
while IFS= read -r skillmd; do
  dir="$(cd "$(dirname "$skillmd")" && pwd -P)"
  is_nested "$dir" || SKILLS+=("$dir")
done < <(find "$REPO_ROOT" -name SKILL.md -not -path '*/.git/*' | sort)

if [ "${#SKILLS[@]}" -eq 0 ]; then
  echo "No SKILL.md found under $REPO_ROOT" >&2; exit 1
fi

# --- Collisions: two skills with the same basename would fight for one link ---
dups="$(for d in "${SKILLS[@]}"; do basename "$d"; done | sort | uniq -d)"
if [ -n "$dups" ]; then
  while IFS= read -r name; do
    echo "name collision: $name" >&2
    for d in "${SKILLS[@]}"; do [ "$(basename "$d")" = "$name" ] && echo "  $d" >&2; done
  done <<<"$dups"
  exit 1
fi

# Cursor reads ~/.claude/skills already; linking into its own dirs duplicates skills.
warn_duplicate_target() {
  local real dup dup_real
  real="$(cd "$1" && pwd -P)"
  for dup in "$HOME/.agents/skills" "$HOME/.cursor/skills"; do
    dup_real="$(cd "$dup" 2>/dev/null && pwd -P || echo "$dup")"
    if [ "$real" = "$dup_real" ]; then
      echo "warning: Cursor already reads ~/.claude/skills; linking into $1 duplicates skills in Cursor" >&2
    fi
  done
}

# --- Install ---
for target in "${TARGETS[@]}"; do
  mkdir -p "$target"
  warn_duplicate_target "$target"
  linked=0; ok=0; skipped=0; pruned=0

  for src in "${SKILLS[@]}"; do
    name="$(basename "$src")"
    dest="$target/$name"

    # Our own link, but dangling (skill moved category): replace it.
    if points_into_repo "$dest" && [ ! -e "$dest" ]; then rm "$dest"; fi

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
      echo "ok       $name"; ok=$((ok + 1)); continue
    fi
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      echo "skip     $name (exists, not ours: $dest)"; skipped=$((skipped + 1)); continue
    fi

    if [ "$MODE" = "copy" ]; then
      cp -R "$src" "$dest"; echo "copied   $name"
    else
      ln -s "$src" "$dest"; echo "linked   $name"
    fi
    linked=$((linked + 1))
  done

  if [ "$PRUNE" -eq 1 ]; then
    for entry in "$target"/*; do
      if points_into_repo "$entry" && [ ! -e "$entry" ]; then
        rm "$entry"; echo "pruned   $(basename "$entry")"; pruned=$((pruned + 1))
      fi
    done
  fi

  echo "$target: found ${#SKILLS[@]} · new $linked · ok $ok · skipped $skipped · pruned $pruned"
done

echo "Restart your agent (or /reload-plugins in Claude Code) to pick up changes."
```

- [ ] **Step 4: Run tests, verify all pass**

Run: `chmod +x install.sh tests/install.test.sh && bash tests/install.test.sh`
Expected: 13 `PASS` lines, `all passed`, exit 0.

- [ ] **Step 5: Smoke-test help and the real repo without touching real config**

Run: `./install.sh --help | head -3 && tmp=$(mktemp -d) && HOME=$tmp CLAUDE_CONFIG_DIR=$tmp/.claude ./install.sh && ls $tmp/.claude/skills; rm -rf $tmp`
Expected: help output's first non-empty line is `install.sh — link this repo's skills…`; install lists the repo's current skills with `linked`, no collisions.

- [ ] **Step 6: Commit**

```bash
git add install.sh tests/install.test.sh
git commit -m "feat(install): add prune, --target, nested and collision checks

Default target stays ~/.claude/skills, which Cursor also reads, so one
link serves both harnesses. Stale links into the repo are relinked;
--prune drops dangling ones. Drops agent installation (agents/ is empty).

Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"
```

---

### Task 2: scripts/upstream-diff.sh (TDD)

**Files:**
- Create: `tests/upstream-diff.test.sh`
- Create: `scripts/upstream-diff.sh`

**Interfaces:**
- Consumes: `UPSTREAM.md` format from Global Constraints.
- Produces: CLI `scripts/upstream-diff.sh <skill-dir>`. Prints `upstream: <Source> @ <sha>`, `pinned:   <Pinned>`, then unified diff (upstream path first, local second). Exit 0 when diff runs (with or without differences); 1 on missing `UPSTREAM.md`, missing `Source:`, clone failure, or missing upstream path; 2 on wrong arg count.

- [ ] **Step 1: Write the failing test file**

Create `tests/upstream-diff.test.sh`:

```bash
#!/usr/bin/env bash
# tests/upstream-diff.test.sh — uses a local file:// git repo as the "upstream".
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SCRIPT="$HERE/../scripts/upstream-diff.sh"
fails=0
check() {
  if [ "$2" -eq 0 ]; then echo "PASS  $1"; else echo "FAIL  $1"; fails=$((fails + 1)); fi
}

root="$(cd "$(mktemp -d)" && pwd -P)"
trap 'rm -rf "$root"' EXIT

# Upstream repo with the skill under skills/demo
mkdir -p "$root/up/skills/demo"
printf 'line one\nline two\n' > "$root/up/skills/demo/SKILL.md"
git -C "$root/up" init -q
git -C "$root/up" -c user.name=t -c user.email=t@t add -A
git -C "$root/up" -c user.name=t -c user.email=t@t commit -qm init

# Local vendored copy with one modified line
mkdir -p "$root/local/demo"
printf 'line one\nline TWO local\n' > "$root/local/demo/SKILL.md"
cat > "$root/local/demo/UPSTREAM.md" <<EOF
Source: file://$root/up
Path: /skills/demo
License: MIT
Pinned: v0 @ abc (2026-09-24)

## Local changes
- line two edited
EOF

# 1. shows the local modification, exits 0
out="$(bash "$SCRIPT" "$root/local/demo" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] && grep -q '^-line two' <<<"$out" && grep -q '^+line TWO local' <<<"$out" && grep -q '^upstream: ' <<<"$out"
check "shows local diff and exits 0" $?

# 2. UPSTREAM.md itself is excluded from the diff
! grep -q 'Only in .*UPSTREAM.md' <<<"$out"
check "UPSTREAM.md excluded" $?

# 3. read-only: local dir unchanged
before="$(cd "$root/local/demo" && cat SKILL.md UPSTREAM.md | cksum)"
bash "$SCRIPT" "$root/local/demo" >/dev/null 2>&1
after="$(cd "$root/local/demo" && cat SKILL.md UPSTREAM.md | cksum)"
[ "$before" = "$after" ] && [ "$(ls -A "$root/local/demo" | wc -l)" -eq 2 ]
check "read-only" $?

# 4. missing UPSTREAM.md → exit 1
mkdir -p "$root/local/bare"
bash "$SCRIPT" "$root/local/bare" >/dev/null 2>&1; rc=$?
[ "$rc" -eq 1 ]
check "missing UPSTREAM.md exits 1" $?

# 5. missing Source: → exit 1
mkdir -p "$root/local/nosrc"; echo "Path: /" > "$root/local/nosrc/UPSTREAM.md"
bash "$SCRIPT" "$root/local/nosrc" >/dev/null 2>&1; rc=$?
[ "$rc" -eq 1 ]
check "missing Source exits 1" $?

# 6. wrong arg count → exit 2
bash "$SCRIPT" >/dev/null 2>&1; rc=$?
[ "$rc" -eq 2 ]
check "no args exits 2" $?

# 7. upstream path missing → exit 1
mkdir -p "$root/local/badpath"
printf 'Source: file://%s/up\nPath: /nope\n' "$root" > "$root/local/badpath/UPSTREAM.md"
bash "$SCRIPT" "$root/local/badpath" >/dev/null 2>&1; rc=$?
[ "$rc" -eq 1 ]
check "missing upstream path exits 1" $?

echo
[ "$fails" -eq 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
```

- [ ] **Step 2: Run, verify it fails**

Run: `bash tests/upstream-diff.test.sh`
Expected: exits 1; cases 1, 2, 4, 5, 6, 7 `FAIL` (script does not exist → bash exits 127).

- [ ] **Step 3: Write `scripts/upstream-diff.sh`**

```bash
#!/usr/bin/env bash
#
# upstream-diff.sh — show how a vendored skill differs from its upstream.
#
# Usage: scripts/upstream-diff.sh <skill-dir>
#
# Reads Source: and Path: from <skill-dir>/UPSTREAM.md, shallow-clones Source
# into a temp dir, and diffs upstream Path (left) against the local copy (right).
# Read-only: never writes to the repo. Merging upstream changes is manual.

set -euo pipefail

if [ $# -ne 1 ]; then echo "usage: $0 <skill-dir>" >&2; exit 2; fi

dir="${1%/}"
meta="$dir/UPSTREAM.md"
[ -f "$meta" ] || { echo "no UPSTREAM.md in $dir" >&2; exit 1; }

field() { sed -n "s/^$1:[[:space:]]*//p" "$meta" | head -n 1; }

src="$(field Source)"
path="$(field Path)"
[ -n "$src" ] || { echo "$meta: missing Source:" >&2; exit 1; }
path="${path:-/}"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

git clone -q --depth 1 "$src" "$tmp/up" 2>/dev/null || { echo "clone failed: $src" >&2; exit 1; }
up="$tmp/up/${path#/}"
[ -d "$up" ] || { echo "path not found upstream: $path" >&2; exit 1; }

echo "upstream: $src @ $(git -C "$tmp/up" rev-parse HEAD)"
echo "pinned:   $(field Pinned)"
diff -ru --exclude=.git --exclude=UPSTREAM.md "$up" "$dir" || true
```

- [ ] **Step 4: Run, verify all pass**

Run: `chmod +x scripts/upstream-diff.sh tests/upstream-diff.test.sh && bash tests/upstream-diff.test.sh`
Expected: 7 `PASS`, `all passed`, exit 0.

- [ ] **Step 5: Commit**

```bash
git add scripts/upstream-diff.sh tests/upstream-diff.test.sh
git commit -m "feat(scripts): add upstream-diff for vendored skills

Reads Source/Path from UPSTREAM.md, shallow-clones upstream to a temp
dir and diffs it against the local copy. Read-only.

Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"
```

---

### Task 3: Repo content — remove, move in, vendor

**Files:**
- Delete: `agents/`, `.claude-plugin/`, `code/project-docs/` (deletion already staged from the cleanup; README/manifest edits for it are unstaged)
- Create: `code/git/committing-changes/SKILL.md`
- Create: `writing/humanizer/**`, `writing/humanizer/UPSTREAM.md`
- Modify: `skills.sh.json`, `.gitignore`

**Interfaces:**
- Consumes: `install.sh` (Task 1) for verification; `scripts/upstream-diff.sh` (Task 2).
- Produces: skill names `committing-changes` and `humanizer` at the paths above (README in Task 4 links them).

- [ ] **Step 1: Remove agents/, .claude-plugin/, and finish project-docs removal**

```bash
git rm -rqf agents .claude-plugin               # -f: manifests have unstaged edits from the cleanup
git checkout -- README.md 2>/dev/null || true   # README is fully rewritten in Task 4
git status --short
```
Expected: `D` for `agents/.gitkeep`, `.claude-plugin/*`, `code/project-docs/**`; `skills.sh.json` still modified (project-docs group removed) — keep that change.

- [ ] **Step 2: Move committing-changes in, made repo-agnostic**

```bash
mkdir -p code/git/committing-changes
cp ~/.claude/skills/committing-changes/SKILL.md code/git/committing-changes/SKILL.md
```

Then edit `code/git/committing-changes/SKILL.md`:

- Line 3 — replace `git in this repository — at a logical checkpoint` with `git in the current repository — at a logical checkpoint`.
- Line 21 — replace `You ARE authorized to create local git commits in this repository, following the rules below` with `You ARE authorized to create local git commits in the current repository, following the rules below`.
- Lines 28–32 — replace the trailer block with:

```markdown
2. **Co-author trailer** — every commit message ends with a blank line then the
   attribution line your harness provides (e.g. a system reminder). If none is given, use
   `Co-Authored-By: <your model name> <noreply@anthropic.com>`.
   (The committer stays the human git user; the model is credited as co-author.)
```

- In the three example blocks (lines ~83, 88, 93), replace `Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>` with `Co-Authored-By: <model name> <noreply@anthropic.com>`.

Verify: `grep -n "this repository\|Haiku 4.5" code/git/committing-changes/SKILL.md` → no output.

- [ ] **Step 3: Vendor humanizer from upstream**

```bash
tmp=$(mktemp -d)
git clone -q --depth 1 https://github.com/blader/humanizer "$tmp/h"
sha=$(git -C "$tmp/h" rev-parse HEAD)
ver=$(sed -n 's/^ *version: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/p' "$tmp/h/SKILL.md" | head -1)
echo "$ver @ $sha"
mkdir -p writing/humanizer
cp -R "$tmp/h/." writing/humanizer/
rm -rf writing/humanizer/.git
find writing/humanizer -name SKILL.md
rm -rf "$tmp"
```
Expected: version `3.x`; exactly one `SKILL.md` (`writing/humanizer/SKILL.md`). If a nested `SKILL.md` appears, leave it — `install.sh` skips nested skills — and note it under Local changes as "none (nested SKILL.md at <path> is not installed separately)".

Create `writing/humanizer/UPSTREAM.md` with the real values printed above:

```markdown
Source: https://github.com/blader/humanizer
Path: /
License: MIT
Pinned: v<ver> @ <sha> (2026-09-24)

## Local changes
- none
```

Verify:
- `python3 writing/humanizer/scripts/validate-package.py` (if the script exists) → passes.
- `scripts/upstream-diff.sh writing/humanizer` → prints `upstream:` line and **no diff lines**.

- [ ] **Step 4: Update skills.sh.json**

Final content:

```json
{
  "$schema": "https://skills.sh/schemas/skills.sh.schema.json",
  "notGrouped": "bottom",
  "groupings": [
    {
      "title": "Git",
      "description": "code/git — lean, domain-separated Conventional Commits.",
      "skills": ["committing-changes"]
    },
    {
      "title": "Review",
      "description": "code/review — session-aftermath hygiene after large diffs. Reports only.",
      "skills": ["hygiene-review"]
    },
    {
      "title": "Tests",
      "description": "code/tests — behavior coverage: flows, business rules, happy and bad paths.",
      "skills": ["behavior-tests"]
    },
    {
      "title": "Benchmark",
      "description": "code/benchmark — disposable A-vs-B comparisons; answer over code.",
      "skills": ["compare-alternatives"]
    },
    {
      "title": "Product",
      "description": "product/ — landing, pricing, and viral-product positioning critique.",
      "skills": ["viral-product-review"]
    },
    {
      "title": "Writing",
      "description": "writing/ — humanizer (vendored) plus critique and collaborative rewrite of technical posts.",
      "skills": ["humanizer", "blog-critic", "blog-refiner"]
    }
  ]
}
```

Verify: `python3 -m json.tool skills.sh.json >/dev/null && echo ok`.

- [ ] **Step 5: Update .gitignore**

Final content:

```gitignore
.omc/
*.skill
*:Zone.Identifier

# Public repo: never commit credential-shaped files.
.env
.env.*
*.key
*.pem
*secret*
*credentials*
```

Verify: `grep -c token .gitignore` → `0`; `git status --short --ignored writing/humanizer | grep '^!!'` → no output (nothing from the vendored package got ignored).

- [ ] **Step 6: Verify install on a temp HOME**

Run: `tmp=$(mktemp -d); HOME=$tmp CLAUDE_CONFIG_DIR=$tmp/.claude ./install.sh; ls $tmp/.claude/skills; rm -rf $tmp; bash tests/install.test.sh; bash tests/upstream-diff.test.sh`
Expected: 8 skills linked (behavior-tests, blog-critic, blog-refiner, committing-changes, compare-alternatives, humanizer, hygiene-review, viral-product-review); no collisions; both test suites `all passed`.

- [ ] **Step 7: Commit (three commits, one concern each)**

```bash
# Index holds only the removals staged in Step 1 (nothing else was `git add`ed yet).
git diff --cached --name-status | grep -v '^D' && echo "unexpected staged changes — stop" || true
git commit -m "refactor!: drop plugin marketplace, empty agents dir and project-docs

install.sh plus skills.sh cover every install path; the marketplace
duplicated skills when combined with symlinks.

BREAKING CHANGE: /plugin marketplace add carvalhosauro/skills no longer works.

Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"

git add code/git/committing-changes
git commit -m "feat(git): move committing-changes into the repo

Made repository-agnostic: no 'this repository' wording and the
co-author trailer comes from the harness instead of a fixed model.

Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"

git add writing/humanizer skills.sh.json .gitignore
git commit -m "feat(writing): vendor humanizer from blader/humanizer

Pinned in UPSTREAM.md; register Git and humanizer groups in
skills.sh.json; block credential-shaped files in .gitignore.

Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"
```

---

### Task 4: README rewrite

**Files:**
- Modify (full rewrite): `README.md`

**Interfaces:**
- Consumes: skill names/paths from Task 3; `install.sh` flags from Task 1; `scripts/upstream-diff.sh` from Task 2.
- Produces: nothing consumed by code.

- [ ] **Step 1: Write README.md**

````markdown
# skills

> **These are Gustavo Carvalho's personal skills** — tailored to my machines,
> subscriptions, and workflow. They are published for reference. Treat them as
> examples, then ask your own LLM to adapt them to your needs instead of reusing
> them verbatim: they carry my assumptions and paths.

Single versioned source for the [Agent Skills](https://agentskills.io) I use —
my own and third-party ones with light local changes. Each harness's skills
directory holds per-skill symlinks into this repo, so one edit here reaches all
of them and `git pull` updates everything.

## Layout

Categories, one directory per skill, each with a `SKILL.md`.

```
skills/
├── code/
│   ├── git/committing-changes
│   ├── review/hygiene-review
│   ├── tests/behavior-tests
│   └── benchmark/compare-alternatives
├── writing/
│   ├── humanizer            (vendored — see UPSTREAM.md)
│   └── blog/{blog-critic,blog-refiner}
├── product/viral-product-review
├── scripts/upstream-diff.sh
└── tests/
```

## Catalog

| Skill | Category | Origin | What it does |
|---|---|---|---|
| committing-changes | code/git | own | Lean, domain-separated Conventional Commits with a co-author trailer. |
| hygiene-review | code/review | own | Post-session readability and hygiene review via parallel subagents. Reports only. |
| behavior-tests | code/tests | own | Behavior coverage: flows, business rules, happy and bad paths. |
| compare-alternatives | code/benchmark | own | Throwaway A-vs-B code with a measured verdict. |
| humanizer | writing | vendored: [blader/humanizer](https://github.com/blader/humanizer) | Rewrites AI-sounding prose so it reads naturally. |
| blog-critic | writing/blog | own | Socratic critique of technical posts (PT or EN). |
| blog-refiner | writing/blog | own | Section-by-section rewrite that keeps the author's voice. |
| viral-product-review | product | own, from Marc Lou's 32 principles | Audits landing page, pricing, and positioning. |

## Install

### Me — install.sh (symlinks)

```bash
git clone git@github.com:carvalhosauro/skills.git
cd skills && ./install.sh --prune
```

| Flag | Meaning |
|---|---|
| *(none)* | Link every skill into `${CLAUDE_CONFIG_DIR:-~/.claude}/skills`. |
| `--target DIR` | Also link into `DIR` (repeatable), e.g. `~/.codex/skills`. |
| `--prune` | After installing, remove dangling links into this repo. |
| `--copy` | Copy instead of symlink (snapshot; won't track `git pull`). |
| `--uninstall` | Remove every link into this repo from each target. |

It never overwrites or deletes anything that is not a symlink into this repo.
Restart the agent afterwards.

### Others — skills.sh

```bash
npx skills add carvalhosauro/skills --list
npx skills add carvalhosauro/skills --skill humanizer -g -y -a claude-code -a cursor
```

## Consumers

| Harness | Skills directory | How it links |
|---|---|---|
| Claude Code | `~/.claude/skills` | per-skill symlinks (default target) |
| Cursor | reads `~/.claude/skills` as a compatibility dir | nothing extra — linking into `~/.cursor/skills` or `~/.agents/skills` would show duplicates |
| Others (Codex, …) | e.g. `~/.codex/skills` | `./install.sh --target <dir>` |

Per-skill symlinks rather than one directory symlink: the harness directories
also hold entries that must not live here (below).

## Deliberately NOT in this repo

- **run-on-device** — lives in the pigz mobile repo (`tools/run-on-device`) and is
  linked from there; it only makes sense inside that project.
- **Work skills** — private; not published in a public repo.
- **Plugin-provided skills** — superpowers, caveman, figma: installed and updated as
  Claude Code plugins.
- **claude.ai synced skills** — `~/.claude/skills/synced/`, managed by account sync.

## External components

None of these auto-update; re-check occasionally.

| Component | Source | Where it lives | Update procedure |
|---|---|---|---|
| humanizer | [blader/humanizer](https://github.com/blader/humanizer) | vendored in `writing/humanizer/` | `scripts/upstream-diff.sh writing/humanizer`, merge by hand, bump `Pinned:` and `Local changes` in `UPSTREAM.md` |
| superpowers, figma, github, gopls-lsp, php-lsp | [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) | Claude Code plugins | `claude plugin update <name>` |
| caveman | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | Claude Code plugin | `claude plugin update caveman` |
| intelephense | npm `intelephense` | global npm (needed by php-lsp) | `npm i -g intelephense@latest` |
| ai-memory | [akitaonrails/ai-memory](https://github.com/akitaonrails/ai-memory) | Docker container `ai-memory` + hooks/MCP in Claude Code and Cursor | `ai-memory upgrade` |
| rtk | [rtk-ai/rtk](https://github.com/rtk-ai/rtk) | `~/.local/bin/rtk` + Claude Code Bash hook | re-run the upstream installer |
| statusline | this machine | `~/.claude/statusline.py` | edit in place |

Last checked 2026-09-24 — humanizer <ver from UPSTREAM.md>, superpowers 6.4.1,
figma 2.2.120, ai-memory 2.4.0, rtk 0.34.2.

## Rules

This repo is public. `.gitignore` blocks credential-shaped files (`.env`,
`.env.*`, `*.key`, `*.pem`, `*secret*`, `*credentials*`). Never commit anything
resembling a key, token, or private work material.

Vendored skills keep their upstream `LICENSE`, have `.git` stripped, and carry an
`UPSTREAM.md` (`Source:`, `Path:`, `License:`, `Pinned:`, `## Local changes`).
Skills only *inspired by* another project get a credit in the Catalog and no copy.

## Adding a skill

1. Create `<category>/<name>/SKILL.md`.
2. Add it to a group in `skills.sh.json` and a row in the Catalog.
3. `./install.sh`, then restart the agent.

Vendoring instead: clone upstream, copy the skill directory, `rm -rf .git`, add
`UPSTREAM.md`, and confirm `scripts/upstream-diff.sh <dir>` shows no diff.

## Tests

```bash
bash tests/install.test.sh
bash tests/upstream-diff.test.sh
```
````

Replace `<ver from UPSTREAM.md>` with the `Pinned:` version from `writing/humanizer/UPSTREAM.md` before saving.

- [ ] **Step 2: Verify README matches the repo**

Run:
```bash
grep -q '<ver' README.md && echo "placeholder left" || echo ok
for s in $(find . -name SKILL.md -not -path './.git/*' | xargs -n1 dirname | xargs -n1 basename | sort -u); do grep -q "^| $s " README.md || echo "missing in catalog: $s"; done
```
Expected: `ok`; no `missing in catalog` lines (nested humanizer sub-skills, if any, may appear — ignore only those inside `writing/humanizer/`).

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: rewrite README in the shape of akitaonrails/my-skills

Catalog with origin column, consumers table, deliberately-excluded
list, external components with update procedures, rules, tests.

Co-Authored-By: Claude Opus 5.5 (1M context) <noreply@anthropic.com>"
```

---

### Task 5: Migrate this machine and verify in Claude Code and Cursor

**Files:** none in the repo (machine state only).

**Interfaces:**
- Consumes: final repo from Tasks 1–4.

- [ ] **Step 1: Back up current skill dirs**

```bash
mkdir -p ~/.claude/backups && tar czf ~/.claude/backups/pre-foundation-migration.tgz -C ~ .claude/skills .agents/skills .agents/.skill-lock.json
```

- [ ] **Step 2: Replace loose/duplicate copies**

```bash
rm -rf ~/.claude/skills/committing-changes
rm -f ~/.claude/skills/humanizer
rm -rf ~/.agents/skills/humanizer
python3 - <<'EOF'
import json, os
p = os.path.expanduser('~/.agents/.skill-lock.json')
d = json.load(open(p))
(d.get('skills', d)).pop('humanizer', None)
json.dump(d, open(p, 'w'), indent=2)
EOF
```

- [ ] **Step 3: Install with prune**

Run: `cd ~/repo/me/skills && ./install.sh --prune`
Expected: `linked committing-changes`, `linked humanizer`; the other own skills `ok`; `pruned` for nothing or only dangling repo links; `skip` only for non-repo entries (`run-on-device`, `synced`, UI skills linked from `~/.agents`, `impeccable`).

- [ ] **Step 4: Verify in Claude Code**

Start a new `claude` session; run `/skills` (or check the skill list). Expected: `committing-changes` and `humanizer` each listed once.

- [ ] **Step 5: Verify in Cursor (answers the symlink question)**

Open Cursor → Settings → Rules/Skills (agent skills list). Expected: `committing-changes`, `humanizer`, `hygiene-review` listed once each.
- If they are missing: Cursor does not follow symlinks. Run `./install.sh --target ~/.cursor/skills --copy` and add a line to the README Consumers row for Cursor: "Cursor does not follow symlinks — use `--target ~/.cursor/skills --copy` and re-run after `git pull`." Commit as `docs: note Cursor needs copied skills`.
- If duplicates appear: note which directory the second copy comes from and remove it (UI skills in `~/.agents/skills` are expected duplicates until sub-project 2).

- [ ] **Step 6: Report**

Record in the final message: Cursor symlink result, anything skipped, test suite output.
