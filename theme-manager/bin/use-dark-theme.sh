#!/bin/bash

# Alacrity
pushd ~/.config/alacritty/themes
if [ -f current-theme.yaml ]; then
  unlink current-theme.yaml
fi
ln -s dark-theme.yaml current-theme.yaml
popd
touch ~/.config/alacritty/alacritty.yml

# Neovim
pushd ~/.config/nvim/lua/plugins
if [ -f current-theme.lua ]; then
  unlink current-theme.lua
fi
ln -s ../themes/dark-theme.lua  current-theme.lua
popd
