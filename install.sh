#!/usr/bin/env bash
#
# install.sh — install this repo's skills and agents into your Claude config dir.
#
# By default it SYMLINKS each skill into ~/.claude/skills/<name> and each agent
# into ~/.claude/agents/<name>.md, so a later `git pull` updates everything you
# installed. Use --copy to copy instead (a snapshot that won't track the repo).
#
# Usage:
#   ./install.sh              # symlink all skills + agents
#   ./install.sh --copy       # copy instead of symlink
#   ./install.sh --uninstall  # remove the symlinks this repo created
#   ./install.sh --help
#
# Honors $CLAUDE_CONFIG_DIR (defaults to ~/.claude).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$SCRIPT_DIR"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SKILLS_DIR="$CLAUDE_DIR/skills"
AGENTS_DIR="$CLAUDE_DIR/agents"

MODE="link"        # link | copy
ACTION="install"   # install | uninstall

for arg in "$@"; do
  case "$arg" in
    --copy)      MODE="copy" ;;
    --uninstall) ACTION="uninstall" ;;
    -h|--help)
      sed -n '2,18p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "unknown argument: $arg (try --help)" >&2; exit 1 ;;
  esac
done

found=0; changed=0; skipped=0

# Install / uninstall one item. $1=source path, $2=dest path, $3=display label.
# Uses `-ef` (same inode, follows symlinks) so it works for dirs and files and
# never clobbers a path it didn't create.
process() {
  local src="$1" dest="$2" label="$3"
  found=$((found + 1))

  if [ "$ACTION" = "uninstall" ]; then
    if [ -L "$dest" ] && [ "$dest" -ef "$src" ]; then
      rm "$dest"; echo "removed  $label"; changed=$((changed + 1))
    else
      echo "skip     $label (not a link into this repo)"; skipped=$((skipped + 1))
    fi
    return
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ -L "$dest" ] && [ "$dest" -ef "$src" ]; then
      echo "ok       $label (already installed)"; skipped=$((skipped + 1)); return
    fi
    echo "skip     $label (exists, not ours — remove it first: $dest)"; skipped=$((skipped + 1)); return
  fi

  if [ "$MODE" = "copy" ]; then
    cp -R "$src" "$dest"; echo "copied   $label"
  else
    ln -s "$src" "$dest"; echo "linked   $label"
  fi
  changed=$((changed + 1))
}

# --- Skills: every directory containing a SKILL.md (excluding .git) ---
mapfile -t SKILL_FILES < <(find "$REPO_ROOT" -name SKILL.md -not -path '*/.git/*' | sort)
if [ "${#SKILL_FILES[@]}" -eq 0 ]; then
  echo "No SKILL.md files found under $REPO_ROOT" >&2
  exit 1
fi
mkdir -p "$SKILLS_DIR"
for skillmd in "${SKILL_FILES[@]}"; do
  src_dir="$(cd "$(dirname "$skillmd")" && pwd -P)"
  process "$src_dir" "$SKILLS_DIR/$(basename "$src_dir")" "$(basename "$src_dir")"
done

# --- Agents: every *.md under agents/ ---
shopt -s nullglob
AGENT_FILES=("$REPO_ROOT"/agents/*.md)
shopt -u nullglob
if [ "${#AGENT_FILES[@]}" -gt 0 ]; then
  mkdir -p "$AGENTS_DIR"
  for agent in "${AGENT_FILES[@]}"; do
    base="$(basename "$agent")"
    process "$agent" "$AGENTS_DIR/$base" "${base%.md} (agent)"
  done
fi

echo
echo "Skills dir: $SKILLS_DIR"
[ "${#AGENT_FILES[@]}" -gt 0 ] && echo "Agents dir: $AGENTS_DIR"
echo "Found $found · ${ACTION%e}ed $changed · skipped $skipped"
[ "$ACTION" = "install" ] && echo "Run /reload-plugins in Claude Code (or restart) to pick them up."
