#!/bin/bash
# https://github.com/cgerke/dotfiles

# Help
if [ $# -lt 1 ];  then
  echo Requires sudo!
  dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  source "${dir}/help.sh"
	exit
fi

## sudo admin.sh [USERNAME]
## => dsmemberutil checkmembership -U "$1" -G admin | grep 'not' && sudo dseditgroup -o edit -a "$1" -t user admin
sudo dsmemberutil checkmembership -U "$1" -G admin | grep 'not' && sudo dseditgroup -o edit -a "$1" -t user admin
