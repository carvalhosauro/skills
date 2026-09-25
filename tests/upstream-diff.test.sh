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

# 8. UPSTREAM.md with CRLF line endings is still parsed correctly
mkdir -p "$root/local/crlf"
cp "$root/up/skills/demo/SKILL.md" "$root/local/crlf/SKILL.md"
printf 'Source: file://%s/up\r\nPath: /skills/demo\r\n' "$root" > "$root/local/crlf/UPSTREAM.md"
out="$(bash "$SCRIPT" "$root/local/crlf" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] && grep -q '^upstream: ' <<<"$out"
check "CRLF UPSTREAM.md handled" $?

echo
[ "$fails" -eq 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
