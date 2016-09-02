#!/bin/bash
# https://github.com/cgerke/dotfiles
# How to
cat ${0} | fgrep -v cat | fgrep -v '#' | awk '$0="=> "$0'
python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);" $1
