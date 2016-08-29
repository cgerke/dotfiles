#!/bin/bash
# https://github.com/cgerke/dotfiles
# How to
cat ${0} | fgrep -v cat | fgrep -v '#' | awk '$0="=> "$0'
echo "en0: $(networksetup -getMACADDRESS en0 | awk '{print $3}' | sed s/://g)"
echo "en1: $(networksetup -getMACADDRESS en1 | awk '{print $3}' | sed s/://g)"
