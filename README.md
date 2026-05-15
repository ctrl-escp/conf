# conf

Personal development environment. Run `install.sh` on a new machine to get everything set up.

## Install

```bash
./install.sh        # interactive: prompt Y/n for every step
./install.sh -y     # automatic: run all required steps unattended
```

Each step checks whether its target is already installed, installs it if not, then verifies the result. Safe to re-run — existing local config files are never blindly overwritten (see [Update pattern](#update-pattern) below).

### Modes

| Mode | Command | Behaviour |
|------|---------|-----------|
| Interactive | `./install.sh` | Prompts Y/n before each step, including optional steps |
| Automatic | `./install.sh -y` | Runs all required steps; prints optional steps at the end with the commands to run them |
| Selective | `./install.sh <step>...` | Runs only the named steps, in the order given |

### Steps

| Step | Required | What it does |
|------|----------|--------------|
| `prerequisites` | yes | Install git, curl, wget, gpg — required by all subsequent steps |
| `zsh` | yes | Install zsh; set as default shell |
| `oh-my-zsh` | yes | Install Oh My Zsh + autosuggestions + syntax-highlighting plugins |
| `nvm` | yes | Install NVM + Node.js LTS; provides `npm` for later steps |
| `cli-tools` | yes | Install fzf, bat, eza, fd, ripgrep, Neovim 0.11+, tree-sitter-cli (via npm) |
| `dev-tools` | yes | Install Python LSP/formatters, Node.js LSP tools, shellcheck |
| `zsh-config` | yes | Deploy zsh dotfiles |
| `vim-config` | yes | Deploy vim config + run `:PlugInstall` |
| `nvim-config` | yes | Deploy nvim config |
| `eslint-config` | yes | Deploy global ESLint config + `npm install` |
| `sys-tools` | yes | Symlink sys-tools scripts into `/usr/local/bin` |
| `git-config` | optional | Deploy `.gitconfig` and `.gitignore` (skipped in auto mode) |
| `zed-config` | optional | Deploy Zed editor settings (skipped in auto mode) |

Optional steps are prompted in interactive mode. In auto mode (`-y`) they are skipped and printed at the end with the exact command to run each one.

```bash
# Examples
./install.sh nvm cli-tools          # just those two steps
./install.sh git-config zed-config  # optional steps only
```

### How each step works

Every script in `installers/` follows the same pattern:

1. **Check** — if the tool or file is already present, print its version and move on
2. **Install** — run the appropriate install command for the detected OS
3. **Verify** — confirm the expected binary or file exists; exit non-zero on failure

Scripts can be run standalone for debugging:

```bash
bash installers/04-cli-tools.sh
bash installers/08-nvim-config.sh
```


---

## What gets installed

### External tools


| Tool                                         | macOS               | Ubuntu/Debian                          | Fedora | RHEL/CentOS |
| -------------------------------------------- | ------------------- | -------------------------------------- | ------ | ----------- |
| Homebrew                                     | ✓ (prerequisites)   | —                                      | —      | —           |
| git, curl, wget, gpg                         | Xcode CLT / brew    | apt                                    | dnf    | yum         |
| zsh                                          | brew                | apt                                    | dnf    | yum         |
| oh-my-zsh                                    | ✓                   | ✓                                      | ✓      | ✓           |
| NVM + Node LTS                               | ✓                   | ✓                                      | ✓      | ✓           |
| zsh-autosuggestions                          | ✓                   | ✓                                      | ✓      | ✓           |
| zsh-syntax-highlighting                      | ✓                   | ✓                                      | ✓      | ✓           |
| Neovim 0.11+                                 | brew                | GitHub release                         | dnf    | —           |
| fzf, eza, ripgrep (`rg`)                     | brew                | apt                                    | dnf    | manual      |
| bat                                          | brew                | apt as `batcat`; symlinked to `~/.local/bin/bat` | dnf | manual |
| fd                                           | brew                | apt as `fdfind`; symlinked to `~/.local/bin/fd`  | dnf | manual |
| tree-sitter-cli                              | brew                | npm (global)                           | —      | —           |
| Python LSP + formatters                      | pip --user          | pip --user (pip installed via apt)     | pip --user | pip --user |
| typescript-language-server, eslint, prettier | npm (global)        | npm (global)                           | npm (global) | npm (global) |
| shellcheck                                   | brew                | apt                                    | dnf    | —           |


### Configuration files


| What                           | Deployed to                                          |
| ------------------------------ | ---------------------------------------------------- |
| `zsh/.zshrc2`                  | `~/.zshrc2` (always replaced)                        |
| `zsh/.envvars`                 | `~/` (copied once if missing or empty)               |
| `zsh/.aliases-global`          | `~/` (always replaced)                               |
| `zsh/.aliases`                 | `~/` (created once; glob import injected if missing) |
| `zsh/.aliases-local`           | `~/` (created once; not overwritten on update)       |
| oh-my-zsh theme                | `~/.oh-my-zsh/custom/themes/`                        |
| `vim/.vimrc` + runtime         | `~/.vimrc`, `~/.vim/`                                |
| `nvim/nvim-conf.lua`           | `~/.config/nvim/lua/nvim-conf.lua` (always replaced) |
| `git/.gitconfig`, `.gitignore` | `~/` (optional; `./install.sh git-config`; created once) |
| `eslint/`                      | `~/.config/eslint/` + `npm install`                  |
| `sys-tools/*.sh`               | symlinked into `/usr/local/bin/`                     |


### Optional: Zed (`./install.sh zed-config`)


| What                | Deployed to                                     |
| ------------------- | ----------------------------------------------- |
| `zed/settings.json` | `~/.config/zed/settings.json` (always replaced) |


---

## Update pattern

Two files are intentionally never overwritten on update:

- `**~/.zshrc**` — sources `~/.zshrc2` and holds machine-local additions. On first install, if no `.zshrc` exists it's copied from the repo; otherwise `source ~/.zshrc2` is appended to the end. Subsequent installs only replace `.zshrc2`.
- `**~/.config/nvim/init.lua**` — requires `nvim-conf` and holds machine-local additions. Same pattern: created from the repo template on first install, otherwise `require("nvim-conf")` is appended to the end. Subsequent installs only replace `nvim-conf.lua`.

Machine-local aliases go in `~/.aliases-<name>` (e.g. `~/.aliases-work`) — picked up automatically, never touched by this repo.

Local nvim plugins go in `~/.config/nvim/lua/local-plugins.lua` returning a lazy.nvim spec — auto-imported if present.

---

## Tools (`sys-tools/`)

Symlinked into `/usr/local/bin` by `install.sh`.


| Command            | What it does                                                                   |
| ------------------ | ------------------------------------------------------------------------------ |
| `aptdate`          | `apt update && dist-upgrade && autoremove`. Pass `clean` to purge cache first. |
| `pipdate [python]` | Upgrades all outdated pip packages. Accepts an optional Python executable.     |
| `ollama-update`    | Pulls every installed Ollama model and reports which ones changed.             |


---

## Zed settings

`zed/settings.json` contains portable settings only. The following are intentionally excluded and must be configured per-machine after install:

- `**agent_servers**` — custom ACP servers with local project paths
- `**languages.JavaScript.formatter**` — external formatter command
- `**context_servers**` — MCP context servers with local paths

