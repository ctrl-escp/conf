# Configuration Repo
Making it simple to feel at home anywhere.

## Installation
### Install Oh-My-ZSH
Follow the [installation instructions](https://ohmyz.sh/#install):
>$ sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

### Environment
To install the environment simply cd into the [env](env) directory and
> ./install.sh

To add any local aliases simply add a file to the home folder which starts with `.aliases-`, like `.aliases-server`
and fill it with the relevant aliases and exports. It will automatically be picked up when a session starts.

### Setup Vim
Enter vim and enter `:PlugInstall` to download all plugins.

## Available Configurations
### VS-Code
Overwrite the vscode settings with the files in the [settings/vscode](settings/vscode) folder. 