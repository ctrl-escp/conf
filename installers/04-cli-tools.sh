#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

detect_os
print_step "04/12 · Modern CLI tools (fzf, bat, eza, fd, ripgrep, nvim, tree-sitter)"

_load_nvm() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}

_check_tool() {
    local name=$1 cmd=${2:-$1}
    if command_exists "$cmd"; then
        print_already "$name ($($cmd --version 2>&1 | head -1))"
        return 0
    fi
    return 1
}

_verify_tool() {
    local name=$1 cmd=${2:-$1}
    if command_exists "$cmd"; then
        print_verified "$name ($($cmd --version 2>&1 | head -1))"
    else
        print_failed "$name not found after installation"
        exit 1
    fi
}

case $DISTRO in

  # ────────────────────────── macOS ──────────────────────
  macos)
    # pkg:binary — brew package name may differ from the installed binary name
    pairs="fzf:fzf bat:bat eza:eza fd:fd ripgrep:rg tree-sitter:tree-sitter"
    for pair in $pairs; do
        pkg="${pair%%:*}"
        bin="${pair##*:}"
        if ! command_exists "$bin"; then
            print_installing "brew install $pkg"
            brew install "$pkg"
            _verify_tool "$pkg" "$bin"
        else
            _check_tool "$pkg" "$bin"
        fi
    done

    if ! command_exists nvim || ! nvim --version | grep -q "0\.1[1-9]\|0\.[2-9]"; then
        print_installing "brew install neovim"
        brew install neovim
        _verify_tool "nvim"
    else
        _check_tool "nvim"
    fi

    if [ ! -f ~/.fzf.zsh ]; then
        print_installing "Setting up fzf key bindings..."
        "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
        print_verified "fzf key bindings"
    else
        print_already "fzf key bindings (~/.fzf.zsh)"
    fi
    ;;

  # ────────────────── Ubuntu / Debian / WSL ──────────────
  ubuntu|debian|wsl)
    print_installing "apt install fd-find ripgrep bat..."
    sudo apt install -y fd-find ripgrep bat

    # On Debian/Ubuntu these tools install under different binary names.
    # Create ~/.local/bin symlinks so 'fd' and 'bat' work in the shell.
    mkdir -p ~/.local/bin

    if command_exists fdfind; then
        print_verified "fd ($(fdfind --version))"
        if [ ! -e ~/.local/bin/fd ]; then
            ln -s "$(which fdfind)" ~/.local/bin/fd
            print_success "Symlinked fdfind → ~/.local/bin/fd"
        fi
    else
        print_failed "fdfind missing after apt install"; exit 1
    fi

    if command_exists rg; then
        print_verified "rg ($(rg --version | head -1))"
    else
        print_failed "rg missing after apt install"; exit 1
    fi

    if command_exists batcat; then
        print_verified "bat ($(batcat --version))"
        if [ ! -e ~/.local/bin/bat ]; then
            ln -s "$(which batcat)" ~/.local/bin/bat
            print_success "Symlinked batcat → ~/.local/bin/bat"
        fi
    else
        print_failed "batcat missing after apt install"; exit 1
    fi

    # Neovim 0.11+ (apt version is too old)
    needs_nvim=true
    if command_exists nvim; then
        nvim_ver=$(nvim --version | head -1 | sed 's/NVIM v//')
        if printf '%s\n%s\n' "0.11" "$nvim_ver" | sort -V -C 2>/dev/null; then
            needs_nvim=false
            print_already "nvim $nvim_ver"
        fi
    fi
    if $needs_nvim; then
        print_installing "Installing Neovim 0.11+ from GitHub releases..."
        arch=$(uname -m)
        case "$arch" in
            x86_64)  nvim_archive="nvim-linux-x86_64.tar.gz" ;;
            aarch64) nvim_archive="nvim-linux-arm64.tar.gz" ;;
            *)       print_warning "Unsupported arch $arch, skipping Neovim"; nvim_archive="" ;;
        esac
        if [[ -n "$nvim_archive" ]]; then
            tmpdir=$(mktemp -d)
            curl -sL "https://github.com/neovim/neovim/releases/latest/download/$nvim_archive" \
                -o "$tmpdir/nvim.tar.gz"
            sudo tar -xzf "$tmpdir/nvim.tar.gz" -C /usr/local --strip-components=1
            rm -rf "$tmpdir"
            _verify_tool "nvim"
        fi
    fi

    # fzf
    if [ ! -f ~/.fzf.zsh ]; then
        print_installing "Installing fzf..."
        [ ! -d ~/.fzf ] && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --key-bindings --completion --no-update-rc
        print_verified "fzf + key bindings"
    else
        print_already "fzf (~/.fzf.zsh)"
    fi

    # eza
    if command_exists eza; then
        _check_tool "eza"
    else
        print_installing "Installing eza..."
        if ! sudo apt install -y eza 2>/dev/null; then
            print_status "Falling back to manual eza install..."
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
                | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
                | sudo tee /etc/apt/sources.list.d/gierens.list
            sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
            sudo apt update
            sudo apt install -y eza
        fi
        _verify_tool "eza"
    fi

    # tree-sitter (needs npm from nvm)
    _load_nvm
    if command_exists tree-sitter; then
        print_already "tree-sitter ($(tree-sitter --version 2>&1 | head -1))"
    elif command_exists npm; then
        print_installing "npm install -g tree-sitter-cli..."
        npm install -g tree-sitter-cli
        if command_exists tree-sitter; then
            print_verified "tree-sitter $(tree-sitter --version 2>&1 | head -1)"
        else
            print_warning "tree-sitter not found after npm install (PATH may need refresh)"
        fi
    else
        print_warning "npm not found — skipping tree-sitter-cli (run 03-nvm.sh first)"
    fi
    ;;

  # ──────────────────────── Fedora ───────────────────────
  fedora)
    print_installing "dnf install fzf bat fd-find ripgrep eza neovim..."
    sudo dnf install -y fzf bat fd-find ripgrep neovim
    command_exists eza || sudo dnf install -y eza
    for tool in fzf bat rg eza nvim; do _check_tool "$tool" || true; done
    ;;

  # ──────────────────── CentOS / RHEL ────────────────────
  centos|rhel)
    print_warning "Some tools may need manual installation on RHEL/CentOS"
    sudo yum install -y epel-release
    sudo yum install -y ripgrep
    print_status "Please manually install: fzf bat eza fd"
    ;;

  *)
    print_warning "Unknown distro '$DISTRO' — skipping CLI tool installation"
    ;;
esac
