#!/bin/bash
# https://github.com/cgerke/dotfiles

# Help
if (( $EUID != 0 )); then
  echo Requires sudo!
  dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  source "${dir}/help.sh"
	exit
fi

## https://api.chef.io/organizations/trg/getting_started
shopt -s nocasematch
case $1 in
  ## -i install
  i|-i)
    curl -L https://www.opscode.com/chef/install.sh | sudo bash
  ;;
  ## -b bootstrap
  ## cd
  ## knife bootstrap 127.0.0.1 -x bootstrap -i ~/.ssh/id_rsa -N $(scutil --get ComputerName) --sudo --use-sudo-password -P tellevery1 -y -V
  ## knife node run_list add $(scutil --get ComputerName) "role[default]"
  ## knife bootstrap 127.0.0.1 -i ~/.ssh/id_rsa -N $(scutil --get ComputerName) --sudo --use-sudo-password -y -V
  b|-b)
    echo "coming soon..."
  ;;
  ## -q quickstart
  ## sudo chef-client --log_level debug -z -j quickstart.json
  q|-q)
    sudo chef-client --log_level debug -z -j quickstart.json
  ;;
esac
