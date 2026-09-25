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
done < <(find "$REPO_ROOT" -name SKILL.md -not -path '*/.git/*' -not -path "$REPO_ROOT/.*" | sort)

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
      echo "skip     $name (exists, not a current link: $dest)"; skipped=$((skipped + 1)); continue
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
