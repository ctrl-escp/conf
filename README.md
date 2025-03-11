# Configuration Repo
Making it simple to feel at home anywhere.

## Installation
### Install Oh-My-ZSH
Make sure zsh is installed on the system
```shell
sudo apt install zsh
```
or 
```shell
brew install zsh
```

Follow the [installation instructions](https://ohmyz.sh/#install):
```shell
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Environment
To install the environment simply cd into the [env](env) directory and
```shell
./install.sh
```

To add any local aliases simply add a file to the home folder which starts with `.aliases-`, like `.aliases-server`
and fill it with the relevant aliases and exports. It will automatically be picked up when a session starts.

### Setup Vim
Enter vim and enter `:PlugInstall` to download all plugins.

### Setup NVM
Follow [these instructions](https://github.com/nvm-sh/nvm?tab=readme-ov-file#install--update-script).
```shell
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
```