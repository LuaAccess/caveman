#!/usr/bin/env bash
# caveman install.sh — personal fork installer
# Installs only for Claude Code (claude CLI). No network calls. No npx.
# Run from the repo root: bash install.sh
#
# Usage:
#   bash install.sh            # install
#   bash install.sh --dry-run  # preview what would happen
#   bash install.sh --uninstall

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS="$CLAUDE_DIR/settings.json"
DRY=false
UNINSTALL=false

for arg in "$@"; do
  case "$arg" in
    --dry-run)   DRY=true ;;
    --uninstall) UNINSTALL=true ;;
    -h|--help)
      echo "Usage: bash install.sh [--dry-run] [--uninstall]"
      exit 0 ;;
  esac
done

say()  { printf '\033[38;5;172m%s\033[0m\n' "$*"; }
note() { printf '\033[2m%s\033[0m\n' "$*"; }
ok()   { printf '\033[32m%s\033[0m\n' "$*"; }
err()  { printf '\033[31m%s\033[0m\n' "$*" >&2; }

# Check claude CLI is available.
if ! command -v claude &>/dev/null; then
  err "caveman: 'claude' CLI not found. Install Claude Code first."
  exit 1
fi

# Check Node >= 18.
NODE_MAJOR=$(node -e "process.stdout.write(String(parseInt(process.versions.node)))" 2>/dev/null || echo "0")
if [ "$NODE_MAJOR" -lt 18 ]; then
  err "caveman: Node ${NODE_MAJOR} too old. Need Node ≥18."
  exit 1
fi

if $UNINSTALL; then
  say "caveman — uninstalling"
  if $DRY; then note "(dry run — nothing removed)"; fi

  # Remove hook files.
  for f in caveman-activate.js caveman-mode-tracker.js caveman-stats.js caveman-config.js caveman-statusline.sh package.json; do
    p="$HOOKS_DIR/$f"
    if [ -f "$p" ]; then
      $DRY || rm -f "$p"
      note "  removed $p"
    fi
  done

  # Remove plugin.
  if command -v claude &>/dev/null; then
    if claude plugin list 2>/dev/null | grep -qi caveman; then
      $DRY || claude plugin uninstall caveman@caveman 2>/dev/null || true
      ok "  removed claude plugin"
    else
      note "  claude plugin not installed — skipping"
    fi
  fi

  $DRY || rm -f "$CLAUDE_DIR/.caveman-active" "$CLAUDE_DIR/.caveman-statusline-suffix"
  ok "uninstall done."
  exit 0
fi

say "caveman — installing (personal fork)"
if $DRY; then note "(dry run — nothing will be written)"; fi

# 1. Copy hook files.
$DRY || mkdir -p "$HOOKS_DIR"
for f in caveman-activate.js caveman-mode-tracker.js caveman-stats.js caveman-config.js caveman-statusline.sh package.json; do
  src="$REPO_ROOT/src/hooks/$f"
  dest="$HOOKS_DIR/$f"
  if [ ! -f "$src" ]; then
    err "  missing: $src"
    exit 1
  fi
  if $DRY; then
    note "  would copy $src → $dest"
  else
    cp "$src" "$dest"
    note "  installed: $dest"
  fi
done

# Make statusline executable.
$DRY || chmod +x "$HOOKS_DIR/caveman-statusline.sh"

# 2. Wire hooks into settings.json via claude plugin install.
say "→ Installing Claude Code plugin..."

if ! $DRY; then
  if claude plugin list 2>/dev/null | grep -qi caveman; then
    note "  caveman plugin already installed"
  else
    claude plugin install "$REPO_ROOT" || {
      err "  plugin install failed — try: claude plugin install $REPO_ROOT"
      exit 1
    }
    ok "  claude plugin installed"
  fi
else
  note "  would run: claude plugin install $REPO_ROOT"
fi

echo ""
ok "Done!"
note "  Start any Claude Code session and say 'caveman mode' or run /caveman"
note "  Uninstall: bash install.sh --uninstall"
