#!/bin/bash
# https://github.com/cgerke/dotfiles
# How to
cat ${0} | fgrep -v cat | fgrep -v '#' | awk '$0="=> "$0'
system_profiler SPHardwareDataType | grep "Memory" | awk '{print $2$3}'
