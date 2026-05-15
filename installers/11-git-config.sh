#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/lib.sh"

detect_os
print_step "11/12 · Git configuration (optional)"

errors=0
for file in "$CONF_DIR/git"/.*; do
    [ -f "$file" ] || continue
    dest="$HOME/$(basename "$file")"
    if [ -f "$dest" ]; then
        print_already "$(basename "$file") (exists, skipping)"
    else
        cp "$file" "$dest"
        print_success "Copied $(basename "$file")"
    fi
done

# ── Verify ────────────────────────────────────────────────
if [ -f ~/.gitconfig ]; then
    print_verified "~/.gitconfig present"
else
    print_failed "~/.gitconfig missing"
    exit 1
fi
