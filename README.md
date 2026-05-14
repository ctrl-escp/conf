# conf

Personal development environment. Run `install.sh` on a new machine to get everything set up.

## Install

```bash
./install.sh
```

Full setup: installs external tools and deploys all configuration files. Safe to re-run — existing local config files are never blindly overwritten (see [Update pattern](#update-pattern) below).

### Install specific components

Pass one or more component names to install only those, skipping everything else:

```bash
./install.sh zed
./install.sh nvim zed
./install.sh zsh git nvim vim eslint tools zed
```


| Argument | What it installs                       |
| -------- | -------------------------------------- |
| `zsh`    | zsh config files                       |
| `git`    | git config files                       |
| `vim`    | vim config and runtime files           |
| `nvim`   | nvim config files                      |
| `eslint` | global ESLint config + `npm install`   |
| `zed`    | Zed editor settings                    |
| `tools`  | sys-tools symlinks in `/usr/local/bin` |


---

## What gets installed

### External tools


| Tool                                         | macOS | Ubuntu/Debian      | Fedora | RHEL/CentOS |
| -------------------------------------------- | ----- | ------------------ | ------ | ----------- |
| Homebrew                                     | ✓     | —                  | —      | —           |
| zsh                                          | brew  | apt                | dnf    | yum         |
| oh-my-zsh                                    | ✓     | ✓                  | ✓      | ✓           |
| NVM + Node LTS                               | ✓     | ✓                  | ✓      | ✓           |
| zsh-autosuggestions                          | ✓     | ✓                  | ✓      | ✓           |
| zsh-syntax-highlighting                      | ✓     | ✓                  | ✓      | ✓           |
| Neovim 0.11+                                 | brew  | GitHub release     | —      | —           |
| fzf, bat, eza, fd, ripgrep                   | brew  | apt                | dnf    | manual      |
| tree-sitter-cli                              | brew  | npm (global)       | —      | —           |
| Python LSP + formatters                      | ✓     | ✓                  | ✓      | ✓           |
| typescript-language-server, eslint, prettier | ✓     | ✓                  | ✓      | ✓           |
| shellcheck                                   | brew  | apt                | dnf    | —           |


### Configuration files


| What                           | Deployed to                                          |
| ------------------------------ | ---------------------------------------------------- |
| `zsh/.zshrc2`                  | `~/.zshrc2` (always replaced)                        |
| `zsh/.envvars`                 | `~/` (always replaced)                               |
| `zsh/.aliases-global`          | `~/` (always replaced)                               |
| `zsh/.aliases`                 | `~/` (created once; glob import injected if missing) |
| `zsh/.aliases-local`           | `~/` (created once; not overwritten on update)       |
| oh-my-zsh theme                | `~/.oh-my-zsh/custom/themes/`                        |
| `vim/.vimrc` + runtime         | `~/.vimrc`, `~/.vim/`                                |
| `nvim/nvim-conf.lua`           | `~/.config/nvim/lua/nvim-conf.lua` (always replaced) |
| `git/.gitconfig`, `.gitignore` | `~/`                                                 |
| `eslint/`                      | `~/.config/eslint/` + `npm install`                  |
| `sys-tools/*.sh`               | symlinked into `/usr/local/bin/`                     |


### Optional: Zed (`./install.sh zed`)


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

