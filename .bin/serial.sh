#!/bin/bash
# https://github.com/cgerke/dotfiles
# How to
cat ${0} | fgrep -v cat | fgrep -v '#' | awk '$0="=> "$0'
ioreg -l | grep IOPlatformSerialNumber | awk '{print $4}' | cut -d '"' -f 2
