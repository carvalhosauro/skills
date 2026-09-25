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

# 14. dot-directories (e.g. a git worktree checked out under .worktrees/) are
# excluded from discovery, not treated as a name collision
r="$(new_fixture code/a .worktrees/feat/code/a)"
run "$r" >/dev/null; rc=$?
[ "$rc" -eq 0 ] && [ "$(readlink "$r/home/.claude/skills/a")" = "$r/repo/code/a" ]
check "dot-directories excluded from discovery" $?

echo
[ "$fails" -eq 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
