#!/bin/bash
# https://github.com/cgerke/dotfiles
# How to
cat ${0} | fgrep -v cat | fgrep -v '#' | awk '$0="=> "$0'
defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder
