#!/bin/bash
# https://github.com/cgerke/dotfiles

# Help
if [ $# -lt 1 ];  then
    dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    source "${dir}/help.sh"
	exit
fi

## git remote add upstream https://github.com/facebook/IT-CPE.git
## git fetch upstream
## git checkout master
## git reset --hard upstream/master
## git checkout cpe_desktop
## git rebase master
## git push -f origin cpe_desktop
