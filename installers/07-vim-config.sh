#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/lib.sh"

detect_os
print_step "07/12 · Vim configuration"

VIM_SRC="$CONF_DIR/vim"

if [ ! -f "$VIM_SRC/.vimrc" ]; then
    print_warning "vim/.vimrc not found in repo — skipping"
    exit 0
fi

# ── Deploy config files ───────────────────────────────────
cp "$VIM_SRC/.vimrc" ~
print_success "Copied .vimrc"

if [ -d "$VIM_SRC/runtime" ]; then
    mkdir -p ~/.vim
    cp -R "$VIM_SRC/runtime/." ~/.vim/
    print_success "Copied vim runtime files"
fi

# ── Install plugins ───────────────────────────────────────
if command_exists vim; then
    print_installing "Installing vim plugins with vim-plug (vim +PlugInstall +qall)..."
    vim +PlugInstall +qall 2>/dev/null && \
        print_success "Vim plugins installed" || \
        print_warning "vim-plug install exited non-zero — plugins may still be OK"
else
    print_warning "vim not found — run :PlugInstall manually after installing vim"
fi

# ── Verify ────────────────────────────────────────────────
if [ -f ~/.vimrc ]; then
    print_verified "~/.vimrc present"
else
    print_failed "~/.vimrc missing after copy"
    exit 1
fi
