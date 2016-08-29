#!/bin/bash
# https://github.com/cgerke/dotfiles

# is this file is being sourced
[[ $_ = $0 ]] && ls /opt/dotfiles/.bin;

if [ $# -eq 0 ]; then
    echo " "
    fgrep -h "##" "${0}" | fgrep -v fgrep | grep -v _self | sed -e 's/\\$$//' | sed -e 's/##//'
    exit
fi
