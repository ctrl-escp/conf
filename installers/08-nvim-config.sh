#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/lib.sh"

detect_os
print_step "08/12 · Neovim configuration"

NVIM_SRC="$CONF_DIR/nvim"
NVIM_DIR="$HOME/.config/nvim"
REQUIRE_LINE='require("nvim-conf")'

mkdir -p "$NVIM_DIR/lua"

# ── Shared config (always replace) ───────────────────────
if [ -f "$NVIM_SRC/nvim-conf.lua" ]; then
    cp "$NVIM_SRC/nvim-conf.lua" "$NVIM_DIR/lua/nvim-conf.lua"
    print_success "Copied nvim-conf.lua → ~/.config/nvim/lua/nvim-conf.lua"
else
    print_failed "nvim/nvim-conf.lua not found in repo"
    exit 1
fi

# ── init.lua (inject require line if missing) ─────────────
if [ ! -f "$NVIM_DIR/init.lua" ]; then
    cp "$NVIM_SRC/init.lua" "$NVIM_DIR/init.lua"
    print_success "Copied init.lua → ~/.config/nvim/init.lua"
elif grep -qF "$REQUIRE_LINE" "$NVIM_DIR/init.lua"; then
    print_already "init.lua (require line present)"
else
    printf '\n%s\n' "$REQUIRE_LINE" >> "$NVIM_DIR/init.lua"
    print_success "Appended '$REQUIRE_LINE' to existing init.lua"
fi

# ── Verify ────────────────────────────────────────────────
errors=0
[ -f "$NVIM_DIR/lua/nvim-conf.lua" ] || { print_failed "nvim-conf.lua missing"; ((++errors)); }
[ -f "$NVIM_DIR/init.lua" ]          || { print_failed "init.lua missing";       ((++errors)); }
grep -qF "$REQUIRE_LINE" "$NVIM_DIR/init.lua" || \
    { print_failed "init.lua missing require line"; ((++errors)); }

[ $errors -eq 0 ] && print_verified "nvim config deployed" || exit 1
