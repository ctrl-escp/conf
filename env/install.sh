#!/usr/bin/env bash
# ====================================================================
# Complete Development Environment Setup
# ====================================================================
# 1. Installs external tools (zsh, oh-my-zsh, nvm, modern CLI tools)
# 2. Applies your personal configuration files
# Supports: macOS, Linux (Ubuntu/Debian, CentOS/RHEL/Fedora), Windows (WSL)
#
# USAGE: 
#   Run this script from any directory. It will automatically find 
#   configuration files relative to the script location.
#   
#   Examples:
#     ./env/install.sh                    # From project root
#     cd env && ./install.sh              # From env directory  
#     /path/to/conf/env/install.sh        # With absolute path

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Helper functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_section() {
    echo -e "${PURPLE}[SECTION]${NC} $1"
}

# ====================================================================
# PART 1: EXTERNAL TOOLS INSTALLATION
# ====================================================================

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "linux"* ]]; then
        OS="linux"
        if command -v lsb_release >/dev/null 2>&1; then
            DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
        elif [ -f /etc/os-release ]; then
            DISTRO=$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')
        elif [ -f /etc/redhat-release ]; then
            DISTRO="rhel"
        else
            DISTRO="unknown"
        fi
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$WSL_DISTRO_NAME" ]]; then
        OS="windows"
        DISTRO="wsl"
    else
        OS="unknown"
        DISTRO="unknown"
    fi
    
    print_status "Detected OS: $OS ($DISTRO)"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install package manager tools
install_package_manager() {
    case $DISTRO in
        "macos")
            if ! command_exists brew; then
                print_status "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
                # Add Homebrew to PATH for Apple Silicon Macs
                if [[ $(uname -m) == "arm64" ]]; then
                    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                else
                    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
                
                print_success "Homebrew installed"
            else
                print_status "Homebrew already installed"
            fi
            ;;
        "ubuntu"|"debian")
            print_status "Updating package manager..."
            sudo apt update
            ;;
        "fedora"|"centos"|"rhel")
            print_status "Package manager ready"
            ;;
        "wsl")
            if grep -qi ubuntu /etc/os-release 2>/dev/null; then
                sudo apt update
            fi
            ;;
    esac
}

# Install zsh
install_zsh() {
    if ! command_exists zsh; then
        print_status "Installing zsh..."
        case $DISTRO in
            "macos")
                brew install zsh
                ;;
            "ubuntu"|"debian"|"wsl")
                sudo apt install -y zsh
                ;;
            "fedora")
                sudo dnf install -y zsh
                ;;
            "centos"|"rhel")
                sudo yum install -y zsh
                ;;
            *)
                print_error "Unsupported distribution for automatic zsh installation: $DISTRO"
                exit 1
                ;;
        esac
        print_success "Zsh installed"
    else
        print_status "Zsh already installed"
    fi
}

# Install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        print_status "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed"
    else
        print_status "Oh My Zsh already installed"
    fi
}

# Install NVM (Node Version Manager)
install_nvm() {
    if [ ! -d "$HOME/.nvm" ]; then
        print_status "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        
        # Source nvm for current session
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        
        print_success "NVM installed"
        
        # Install latest LTS Node.js
        if command_exists nvm; then
            print_status "Installing latest LTS Node.js..."
            nvm install --lts
            nvm use --lts
            print_success "Node.js LTS installed"
        fi
    else
        print_status "NVM already installed"
    fi
}

# Install zsh external plugins
install_zsh_plugins() {
    local plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
    
    # zsh-autosuggestions
    if [ ! -d "$plugins_dir/zsh-autosuggestions" ]; then
        print_status "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
        print_success "zsh-autosuggestions installed"
    else
        print_status "zsh-autosuggestions already installed"
    fi
    
    # zsh-syntax-highlighting
    if [ ! -d "$plugins_dir/zsh-syntax-highlighting" ]; then
        print_status "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$plugins_dir/zsh-syntax-highlighting"
        print_success "zsh-syntax-highlighting installed"
    else
        print_status "zsh-syntax-highlighting already installed"
    fi
}

# Install modern CLI tools
install_modern_cli_tools() {
    print_status "Installing modern CLI tools..."
    
    case $DISTRO in
        "macos")
            local tools=("fzf" "bat" "eza" "fd" "ripgrep")
            for tool in "${tools[@]}"; do
                if ! command_exists "$tool"; then
                    print_status "Installing $tool..."
                    brew install "$tool"
                else
                    print_status "$tool already installed"
                fi
            done
            
            # Setup fzf key bindings (only if not already configured)
            if command_exists fzf && [ ! -f ~/.fzf.zsh ]; then
                print_status "Setting up fzf key bindings..."
                $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc
            elif command_exists fzf; then
                print_status "FZF key bindings already configured"
            fi
            ;;
            
        "ubuntu"|"debian"|"wsl")
            # Install via apt where available
            sudo apt install -y fd-find ripgrep bat
            
            # Install fzf
            if ! command_exists fzf; then
                git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
                ~/.fzf/install --key-bindings --completion --no-update-rc
            elif [ ! -f ~/.fzf.zsh ]; then
                print_status "Setting up fzf key bindings..."
                ~/.fzf/install --key-bindings --completion --no-update-rc
            else
                print_status "FZF already installed and configured"
            fi
            
            # Install eza (newer systems)
            if ! command_exists eza; then
                # Try to install via package manager first, fallback to manual install
                if ! sudo apt install -y eza 2>/dev/null; then
                    print_status "Installing eza manually..."
                    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
                    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
                    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
                    sudo apt update
                    sudo apt install -y eza
                fi
            fi
            ;;
            
        "fedora")
            sudo dnf install -y fzf bat fd-find ripgrep
            
            # Install eza
            if ! command_exists eza; then
                sudo dnf install -y eza
            fi
            ;;
            
        "centos"|"rhel")
            print_warning "Some modern CLI tools may need manual installation on RHEL/CentOS"
            print_status "Installing available tools..."
            
            # Enable EPEL repository for additional packages
            sudo yum install -y epel-release
            sudo yum install -y ripgrep
            
            # Manual installation for other tools
            print_status "Please manually install: fzf, bat, eza, fd"
            ;;
    esac
    
    print_success "Modern CLI tools installation completed"
}

# Install development language servers and linters
install_development_tools() {
    print_status "Installing development language servers and linters..."
    
    # Python development tools
    if command_exists python3; then
        print_status "Installing Python language servers and formatters..."
        
        local python_tools=("python-lsp-server[all]" "black" "isort" "flake8" "pylint" "mypy")
        local failed_tools=()
        
        for tool in "${python_tools[@]}"; do
            if ! python3 -m pip install --user "$tool" >/dev/null 2>&1; then
                failed_tools+=("$tool")
            fi
        done
        
        if [ ${#failed_tools[@]} -eq 0 ]; then
            print_success "Python development tools installed"
        else
            print_warning "Some Python tools failed to install: ${failed_tools[*]}"
            print_status "You can try installing them manually with: pip install --user ${failed_tools[*]}"
        fi
    else
        print_warning "Python3 not found, skipping Python language server installation"
    fi
    
    # Node.js development tools (if NVM/Node is available)
    if command_exists npm; then
        print_status "Installing Node.js language servers and linters..."
        npm install -g typescript typescript-language-server eslint prettier 2>/dev/null || {
            print_warning "Failed to install some Node.js tools. You may need to install them manually."
        }
        print_success "Node.js development tools installed"
    else
        print_warning "npm not found, skipping Node.js language server installation"
    fi
    
    # Shell scripting tools
    case $DISTRO in
        "macos")
            if ! command_exists shellcheck; then
                brew install shellcheck 2>/dev/null || print_warning "Failed to install shellcheck"
            fi
            ;;
        "ubuntu"|"debian"|"wsl")
            if ! command_exists shellcheck; then
                sudo apt install -y shellcheck 2>/dev/null || print_warning "Failed to install shellcheck"
            fi
            ;;
        "fedora")
            if ! command_exists shellcheck; then
                sudo dnf install -y ShellCheck 2>/dev/null || print_warning "Failed to install shellcheck"
            fi
            ;;
        "centos"|"rhel")
            if ! command_exists shellcheck; then
                print_warning "Please manually install shellcheck for shell script linting"
            fi
            ;;
    esac
    
    if command_exists shellcheck; then
        print_success "Shellcheck installed for shell script linting"
    fi
    
    print_success "Development tools installation completed"
}

# Set zsh as default shell
set_default_shell() {
    local current_shell_name
    current_shell_name=$(basename "$SHELL")
    local target_zsh_path
    target_zsh_path=$(which zsh)
    
    # Check if current shell is already zsh (any version of zsh)
    if [ "$current_shell_name" = "zsh" ]; then
        print_status "Zsh is already the default shell ($SHELL)"
        return
    fi
    
    # If we get here, we need to change the shell to zsh
    print_status "Setting zsh as default shell (current: $SHELL)..."
    
    # Add zsh to /etc/shells if not present
    if ! grep -q "$target_zsh_path" /etc/shells 2>/dev/null; then
        print_status "Adding $target_zsh_path to /etc/shells..."
        echo "$target_zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi
    
    # Change default shell
    if chsh -s "$target_zsh_path"; then
        print_success "Zsh set as default shell (restart terminal to take effect)"
    else
        print_error "Failed to set zsh as default shell. You may need to run: chsh -s $target_zsh_path"
    fi
}

# ====================================================================
# PART 2: CONFIGURATION FILES DEPLOYMENT
# ====================================================================

# Create cache directory for zsh history
create_directories() {
    print_status "Creating necessary directories..."
    mkdir -p ~/.cache/zsh
    print_success "Directories created"
}

# Copy vim configuration and install plugins
install_vim_config() {
    print_status "Installing vim configuration..."
    
    # Get the directory where this script is located
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    if [ -f "$script_dir/.vimrc" ]; then
        cp "$script_dir/.vimrc" ~
        print_success "Copied .vimrc"
    else
        print_warning ".vimrc not found in $script_dir"
        return
    fi
    
    if [ -d "$script_dir/vim" ]; then
        cp -R "$script_dir/vim" ~/.vim
        print_success "Copied vim directory"
    else
        print_warning "vim directory not found in $script_dir"
        return
    fi
    
    # Install vim plugins automatically
    if command_exists vim; then
        print_status "Installing vim plugins with vim-plug..."
        vim +PlugInstall +qall 2>/dev/null
        print_success "Vim plugins installed"
        
        # Install CoC extensions
        print_status "Installing CoC language server extensions..."
        vim +"CocInstall -sync coc-python coc-tsserver coc-json coc-html coc-css coc-yaml coc-sh coc-prettier coc-eslint" +qall 2>/dev/null
        print_success "CoC extensions installed"
    else
        print_warning "Vim not found, skipping plugin installation"
        print_status "After installation, run these commands in vim:"
        print_status "  :PlugInstall"
        print_status "  :CocInstall coc-python coc-tsserver coc-sh coc-json coc-prettier coc-eslint"
    fi
}

# Copy zsh configuration
install_zsh_config() {
    print_status "Installing zsh configuration..."
    
    # Get the directory where this script is located
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Copy configuration files
    local files=(".aliases" ".envvars" ".zshrc")
    local files_copied=0
    
    for file in "${files[@]}"; do
        if [ -f "$script_dir/$file" ]; then
            cp "$script_dir/$file" ~
            print_success "Copied $file"
            ((files_copied++))
        else
            print_warning "$file not found in $script_dir"
        fi
    done
    
    # Copy any .git* files (like .gitconfig, .gitignore_global)
    local git_files_copied=0
    for file in "$script_dir"/.git*; do
        if [ -f "$file" ]; then
            cp "$file" ~
            print_success "Copied $(basename "$file")"
            ((git_files_copied++))
        fi
    done
    
    if [ $files_copied -eq 0 ] && [ $git_files_copied -eq 0 ]; then
        print_warning "No configuration files found to copy"
    fi
}

# Main installation function
main() {
    echo "======================================================================"
    echo "🚀 Complete Development Environment Setup"
    echo "======================================================================"
    echo
    
    detect_os
    
    if [[ $OS == "unknown" ]]; then
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
    
    echo
    print_section "PHASE 1: Installing External Tools"
    echo "======================================================================"
    
    install_package_manager
    install_zsh
    install_oh_my_zsh
    install_nvm
    install_zsh_plugins
    install_modern_cli_tools
    install_development_tools
    set_default_shell
    
    echo
    print_section "PHASE 2: Deploying Configuration Files"
    echo "======================================================================"
    
    create_directories
    install_vim_config
    install_zsh_config
    
    echo
    echo "======================================================================"
    print_success "🎉 Setup completed!"
    echo "======================================================================"
    echo
    print_status "Installation Summary:"
    echo "  ✅ External tools verified/installed"
    echo "  ✅ Development environment configured"
    echo "  ✅ Modern CLI tools available"
    echo "  ✅ Language servers and linters ready"
    echo
    print_status "Your development environment includes:"
    echo "  🧠 Intellisense for Python, Node.js/TypeScript, and shell scripts"
    echo "  🔍 Fuzzy file search with FZF integration"
    echo "  📝 Auto-formatting and linting for multiple languages"
    echo "  🎨 Modern vim with LSP support and enhanced UI"
    echo "  ⚡ Enhanced zsh with autosuggestions and syntax highlighting"
    echo
    print_status "Next steps:"
    echo "1. Restart your terminal or run: exec zsh"
    echo "2. Open vim to verify plugins are working"
    echo "3. Enjoy your development environment! 🚀"
    echo
    print_status "Note: Configuration files are managed in $(dirname "${BASH_SOURCE[0]}")"
}

# Check if running with sudo (we don't want that for most operations)
if [[ $EUID -eq 0 && -z "$SUDO_USER" ]]; then
    print_error "Please don't run this script as root. It will use sudo when needed."
    exit 1
fi

# Run main function
main "$@"