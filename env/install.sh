#!/usr/bin/env zsh
echo "Copying vim settings..."
cp .vimrc ~
cp -R vim ~/.vim

echo "Copying zsh settings..."
cp .aliases ~
cp .paths ~
cp .zshrc ~

echo "Enjoy :)"