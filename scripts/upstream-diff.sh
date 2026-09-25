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
