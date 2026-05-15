#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/lib.sh"

detect_os
print_step "09/12 · ESLint global config"

_load_nvm() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}

SRC="$CONF_DIR/eslint"
DEST="$HOME/.config/eslint"

if [ ! -f "$SRC/eslint.config.mjs" ]; then
    print_warning "eslint/eslint.config.mjs not found in repo — skipping"
    exit 0
fi

# ── Deploy config files ───────────────────────────────────
mkdir -p "$DEST"
cp "$SRC/eslint.config.mjs"          "$DEST/"
cp "$SRC/eslint-vscode-resolver.mjs" "$DEST/"
cp "$SRC/package.json"               "$DEST/"
print_success "Copied ESLint config files to ~/.config/eslint/"

# ── Install npm dependencies ──────────────────────────────
_load_nvm
if command_exists npm; then
    print_installing "npm install --prefix ~/.config/eslint..."
    npm install --prefix "$DEST" --silent
    if [ -d "$DEST/node_modules" ]; then
        print_verified "ESLint dependencies installed"
    else
        print_warning "node_modules not found after npm install"
    fi
else
    print_warning "npm not found — run 'npm install' in ~/.config/eslint manually"
fi

# ── Verify ────────────────────────────────────────────────
errors=0
[ -f "$DEST/eslint.config.mjs" ]          || { print_failed "eslint.config.mjs missing"; ((++errors)); }
[ -f "$DEST/eslint-vscode-resolver.mjs" ] || { print_failed "eslint-vscode-resolver.mjs missing"; ((++errors)); }

[ $errors -eq 0 ] && print_verified "ESLint config deployed" || exit 1
