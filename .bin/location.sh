#!/bin/bash
# https://github.com/cgerke/dotfiles

# Help
if (( $EUID != 0 )); then
  echo Requires sudo!
  dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  source "${dir}/help.sh"
  exit
fi

uuid=$(system_profiler SPHardwareDataType | grep 'Hardware UUID' | cut -c22-57)
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.locationd.plist
sudo defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd.$uuid LocationServicesEnabled -int 1
sudo chown -R _locationd:_locationd /var/db/locationd
sudo launchctl load /System/Library/LaunchDaemons/com.apple.locationd.plist
