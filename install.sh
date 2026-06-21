#!/usr/bin/env bash
#
# install.sh — install this repo's skills into your Claude Code skills directory.
#
# By default it SYMLINKS each skill into ~/.claude/skills/<name>, so a later
# `git pull` updates every installed skill automatically. Use --copy to copy
# instead (a snapshot that won't track the repo).
#
# Usage:
#   ./install.sh              # symlink all skills into ~/.claude/skills
#   ./install.sh --copy       # copy instead of symlink
#   ./install.sh --uninstall  # remove symlinks that point back into this repo
#   ./install.sh --help
#
# Honors $CLAUDE_CONFIG_DIR (defaults to ~/.claude).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$SCRIPT_DIR"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SKILLS_DIR="$CLAUDE_DIR/skills"

# Resolve a path (following symlinks) to its physical location, or empty.
resolve() { cd "$1" 2>/dev/null && pwd -P; }

MODE="link"        # link | copy
ACTION="install"   # install | uninstall

for arg in "$@"; do
  case "$arg" in
    --copy)      MODE="copy" ;;
    --uninstall) ACTION="uninstall" ;;
    -h|--help)
      sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "unknown argument: $arg (try --help)" >&2; exit 1 ;;
  esac
done

mkdir -p "$SKILLS_DIR"

# Discover skills: every directory that contains a SKILL.md (excluding .git).
mapfile -t SKILL_FILES < <(find "$REPO_ROOT" -name SKILL.md -not -path '*/.git/*' | sort)

if [ "${#SKILL_FILES[@]}" -eq 0 ]; then
  echo "No SKILL.md files found under $REPO_ROOT" >&2
  exit 1
fi

found=0; changed=0; skipped=0

for skillmd in "${SKILL_FILES[@]}"; do
  src_dir="$(cd "$(dirname "$skillmd")" && pwd -P)"
  name="$(basename "$src_dir")"
  dest="$SKILLS_DIR/$name"
  found=$((found + 1))

  if [ "$ACTION" = "uninstall" ]; then
    if [ -L "$dest" ] && [ "$(resolve "$dest")" = "$src_dir" ]; then
      rm "$dest"; echo "removed  $name"; changed=$((changed + 1))
    else
      echo "skip     $name (not a link into this repo)"; skipped=$((skipped + 1))
    fi
    continue
  fi

  # install
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ -L "$dest" ] && [ "$(resolve "$dest")" = "$src_dir" ]; then
      echo "ok       $name (already installed)"; skipped=$((skipped + 1)); continue
    fi
    echo "skip     $name (exists, not ours — remove it first: $dest)"; skipped=$((skipped + 1))
    continue
  fi

  if [ "$MODE" = "copy" ]; then
    cp -R "$src_dir" "$dest"; echo "copied   $name"
  else
    ln -s "$src_dir" "$dest"; echo "linked   $name -> $src_dir"
  fi
  changed=$((changed + 1))
done

echo
echo "Skills dir: $SKILLS_DIR"
echo "Found $found · ${ACTION%e}ed $changed · skipped $skipped"
[ "$ACTION" = "install" ] && echo "Run /reload-plugins in Claude Code (or restart) to pick them up."
