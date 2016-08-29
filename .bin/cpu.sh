#!/bin/bash
# https://github.com/cgerke/dotfiles
# How to
cat ${0} | fgrep -v cat | fgrep -v '#' | awk '$0="=> "$0'
system_profiler SPHardwareDataType | grep "Processor Name" | awk '{print $3$4$5$6$7$8$9}'
