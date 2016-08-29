#!/bin/bash
# https://github.com/cgerke/dotfiles

# Help
if (( $EUID != 0 )); then
  echo Requires sudo!
  dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  source "${dir}/help.sh"
	exit
fi

curl -L https://www.opscode.com/chef/install.sh | sudo bash

## https://api.chef.io/organizations/trg/getting_started
## cd
## knife bootstrap 127.0.0.1 -x bootstrap -i ~/.ssh/id_rsa -N $(scutil --get ComputerName) --sudo --use-sudo-password -P tellevery1 -y -V
## knife node run_list add $(scutil --get ComputerName) "role[default]"
## knife bootstrap 127.0.0.1 -i ~/.ssh/id_rsa -N $(scutil --get ComputerName) --sudo --use-sudo-password -y -V
