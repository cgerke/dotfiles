#!/bin/bash
# https://github.com/cgerke/dotfiles
# How to
cat ${0} | fgrep -v cat | fgrep -v '#' | awk '$0="=> "$0'
ioreg -rd1 -c IOPlatformExpertDevice | grep -E model | awk '{print $3}' | sed 's/\<\"//' | sed 's/\"\>//'
