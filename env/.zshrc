# ====================================================================
# ZSH Configuration - Modern & Optimized
# ====================================================================

# Enable colors and better shell options
autoload -U colors && colors
setopt AUTO_CD               # cd by typing directory name
setopt CORRECT               # spell correction for commands
setopt SHARE_HISTORY         # share history between sessions
setopt HIST_IGNORE_DUPS      # ignore duplicate commands
setopt HIST_IGNORE_SPACE     # ignore commands starting with space
setopt HIST_VERIFY           # verify history expansion
setopt EXTENDED_GLOB         # extended globbing patterns

# ====================================================================
# History Configuration
# ====================================================================
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.cache/zsh/history

# ====================================================================
# Oh My Zsh Configuration
# ====================================================================
export ZSH="$HOME/.oh-my-zsh"

# Theme - Choose your preferred one (uncomment one line)
ZSH_THEME="agnoster"         # Modern, git-aware theme
# ZSH_THEME="af-magic"       # Your original theme
# ZSH_THEME="robbyrussell"   # Clean, minimal theme

# Oh My Zsh options
HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="yyyy-mm-dd"
DISABLE_UPDATE_PROMPT="true"     # Auto-update oh-my-zsh
ENABLE_CORRECTION="true"         # Enable command correction

# ====================================================================
# Plugins - Enhanced for Development
# ====================================================================
plugins=(
  git                    # Git completions & aliases
  docker                 # Docker completions
  docker-compose         # Docker-compose completions
  node                   # Node.js completions
  npm                    # NPM completions
  python                 # Python completions
  brew                   # Homebrew completions
  macos                  # macOS shortcuts (cmd+click, etc.)
  colored-man-pages      # Colorful man pages
  command-not-found      # Package suggestions when command not found
)

# ====================================================================
# Vi Mode Configuration (Streamlined)
# ====================================================================
bindkey -v
export KEYTIMEOUT=1             # Faster vi mode switching (was 5)

# Cursor shape changes for vi modes
function zle-keymap-select {
  case $KEYMAP in
    vicmd) echo -ne '\e[1 q';;      # block cursor for command mode
    viins|main) echo -ne '\e[5 q';; # beam cursor for insert mode
  esac
}
zle -N zle-keymap-select

zle-line-init() {
  zle -K viins                     # start in insert mode
  echo -ne "\e[5 q"                # beam cursor
}
zle -N zle-line-init

echo -ne '\e[5 q'                  # beam cursor on startup
preexec() { echo -ne '\e[5 q'; }   # beam cursor for each prompt

# ====================================================================
# Key Bindings (Essential)
# ====================================================================
# Edit command line in vim
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Basic navigation
bindkey "^?" backward-delete-char
bindkey "^[f" forward-word
bindkey "^[b" backward-word

# Modern navigation (ctrl + arrow keys)
bindkey "\e[1;5C" forward-word      # Ctrl+Right
bindkey "\e[1;5D" backward-word     # Ctrl+Left
bindkey "\eOc" forward-word         # Alt+Right (urxvt)
bindkey "\eOd" backward-word        # Alt+Left (urxvt)

# Deletion shortcuts
bindkey '^H' backward-kill-word     # Ctrl+Backspace
bindkey "\e[3;5~" kill-word         # Ctrl+Delete

# ====================================================================
# Language Environment
# ====================================================================
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# ====================================================================
# Load Oh My Zsh
# ====================================================================
source $ZSH/oh-my-zsh.sh

# ====================================================================
# External Plugins (Install separately for enhanced experience)
# ====================================================================
# zsh-autosuggestions: suggests commands as you type
# Install: git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
[ -f ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh-syntax-highlighting: highlights commands as you type
# Install: git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
[ -f ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ====================================================================
# Modern CLI Tools Integration (Install via: brew install fzf bat eza fd ripgrep)
# ====================================================================
# FZF - Fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Modern ls replacement (eza is the maintained fork of exa)
command -v eza >/dev/null && alias ls='eza --icons' && alias ll='eza -la --icons' && alias l='eza -la --icons -s size'

# Modern cat replacement
command -v bat >/dev/null && alias cat='bat'

# Modern grep replacement
command -v rg >/dev/null && alias grep='rg'

# Modern find replacement
command -v fd >/dev/null && alias find='fd'

# ====================================================================
# Load Custom Configuration Files
# ====================================================================
source ~/.aliases
source ~/.envvars