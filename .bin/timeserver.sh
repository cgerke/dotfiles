#!/bin/bash
# https://github.com/cgerke/dotfiles

# Help
if (( $EUID != 0 )); then
  echo Requires sudo!
  dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  source "${dir}/help.sh"
  exit
fi

## => sudo systemsetup -setusingnetworktime 'on'
## => sudo systemsetup -setnetworktimeserver 'time.asia.apple.com'
sudo systemsetup -setusingnetworktime 'on'
sudo systemsetup -setnetworktimeserver 'time.asia.apple.com'
