#!/bin/bash
# https://github.com/cgerke/dotfiles

# Help
if [ $# -lt 1 ];  then
    dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    source "${dir}/help.sh"
	exit
fi

## # Send mail
## date | mail -s testing your_email@gmail.com
## # Mail queue and delivery errors
## sudo mailq
## # Mail logs to ensure everything is working as expected
## sudo tail -f /var/log/mail.log
## # Mail clear queue
## sudo postsuper -d ALL
