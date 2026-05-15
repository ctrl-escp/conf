#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/lib.sh"

detect_os
print_step "12/12 · Zed editor config (optional)"

SRC="$CONF_DIR/zed/settings.json"
DEST="$HOME/.config/zed/settings.json"

if [ ! -f "$SRC" ]; then
    print_warning "zed/settings.json not found in repo — skipping"
    exit 0
fi

mkdir -p "$HOME/.config/zed"
cp "$SRC" "$DEST"

if [ -f "$DEST" ]; then
    print_verified "Zed settings → $DEST"
else
    print_failed "$DEST missing after copy"
    exit 1
fi
