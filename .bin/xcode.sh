#!/bin/bash
# https://github.com/cgerke/dotfiles

xcode-select -p | grep -v '/Library/Developer/CommandLineTools' && sudo touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
[[ -e "/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress" ]] && echo ":: macos-bin :: installing xcode command line tools"
[[ -e "/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress" ]] && sudo softwareupdate -i -a Command\ Line\ Tools* -v
[[ -e "/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress" ]] && sudo rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
