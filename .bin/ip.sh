#!/bin/bash
# https://github.com/cgerke/dotfiles
# How to
cat ${0} | fgrep -v cat | fgrep -v '#' | awk '$0="=> "$0'
echo "en0: $(ipconfig getifaddr en0)"
echo "en1: $(ipconfig getifaddr en1)"
echo "wan: $(dig +short myip.opendns.com @resolver1.opendns.com)"
