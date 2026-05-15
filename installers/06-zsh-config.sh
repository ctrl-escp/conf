#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/lib.sh"

detect_os
print_step "06/12 · Zsh configuration files"

ZSH_SRC="$CONF_DIR/zsh"

# ── Custom oh-my-zsh theme ────────────────────────────────
theme_src="$ZSH_SRC/.oh-my-zsh/custom/themes/af-magic-enhanced.zsh-theme"
theme_dst="$HOME/.oh-my-zsh/custom/themes/af-magic-enhanced.zsh-theme"
if [ -f "$theme_src" ]; then
    mkdir -p "$HOME/.oh-my-zsh/custom/themes"
    cp "$theme_src" "$theme_dst"
    print_success "Copied af-magic-enhanced theme"
fi

# ── Always-replace shared files ───────────────────────────
for file in .zshrc2 .aliases-global; do
    if [ -f "$ZSH_SRC/$file" ]; then
        cp "$ZSH_SRC/$file" ~
        print_success "Copied $file"
    else
        print_warning "$file not found in zsh/"
    fi
done

# ── .envvars (only if missing or empty) ───────────────────
if [ -f "$ZSH_SRC/.envvars" ]; then
    if [ ! -s ~/.envvars ]; then
        cp "$ZSH_SRC/.envvars" ~/.envvars
        print_success "Copied .envvars"
    else
        print_already ".envvars (non-empty, skipping)"
    fi
fi

# ── .aliases (inject glob import if missing) ──────────────
GLOB_LINE='source ~/.aliases-*'
if [ ! -f ~/.aliases ]; then
    cp "$ZSH_SRC/.aliases" ~/.aliases
    print_success "Copied .aliases"
elif grep -qF "$GLOB_LINE" ~/.aliases; then
    print_already ".aliases (glob import present)"
else
    { echo; echo "$GLOB_LINE > /dev/null 2>&1"; } >> ~/.aliases
    print_success "Injected glob import into existing .aliases"
fi

# ── .aliases-local (create if missing) ────────────────────
if [ ! -f ~/.aliases-local ]; then
    if [[ "$DISTRO" == "macos" ]]; then
        echo "alias brewdate='brew update && brew upgrade'" > ~/.aliases-local
        print_success "Created .aliases-local with brewdate alias"
    else
        cp "$ZSH_SRC/.aliases-local" ~/.aliases-local
        print_success "Created .aliases-local"
    fi
elif [[ "$DISTRO" == "macos" ]] && ! grep -qF "brewdate" ~/.aliases-local; then
    echo "alias brewdate='brew update && brew upgrade'" >> ~/.aliases-local
    print_success "Added brewdate alias to .aliases-local"
else
    print_already ".aliases-local"
fi

# ── .zshrc (inject source line if missing) ────────────────
SOURCE_LINE='source ~/.zshrc2'
if [ ! -f ~/.zshrc ]; then
    cp "$ZSH_SRC/.zshrc" ~/.zshrc
    print_success "Copied .zshrc"
elif grep -qF "$SOURCE_LINE" ~/.zshrc; then
    print_already ".zshrc (source line present)"
else
    printf '\n%s\n' "$SOURCE_LINE" >> ~/.zshrc
    print_success "Appended '$SOURCE_LINE' to existing .zshrc"
fi

mkdir -p ~/.cache/zsh

# ── Verify ────────────────────────────────────────────────
errors=0
[ -f ~/.zshrc2 ]        || { print_failed "~/.zshrc2 missing";        ((++errors)); }
[ -f ~/.aliases-global ] || { print_failed "~/.aliases-global missing"; ((++errors)); }
[ -f ~/.zshrc ]         || { print_failed "~/.zshrc missing";          ((++errors)); }
grep -qF "$SOURCE_LINE" ~/.zshrc || { print_failed "~/.zshrc missing source line"; ((++errors)); }

[ $errors -eq 0 ] && print_verified "zsh config deployed" || exit 1
