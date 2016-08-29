#!/bin/bash
# https://github.com/cgerke/dotfiles

# Help
if (( $EUID != 0 )); then
  echo Requires sudo!
  dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  source "${dir}/help.sh"
  exit
fi

## => sudo /usr/sbin/systemsetup -setremotelogin on
sudo systemsetup -setremotelogin on
