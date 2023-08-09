#!/bin/bash

cd $HOME

git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.doom.emacs.d
~/.doom.emacs.d/bin/doom install
