#!/bin/bash
# https://github.com/cgerke/dotfiles

# Help
if [ $# -lt 1 ];  then
    dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    source "${dir}/help.sh"
	exit
fi

## #User
## dscl -f "/var/db/dslocal/nodes/Default" localonly -create /Local/Target/Users/YOURUSERNAME
## dscl -f "/var/db/dslocal/nodes/Default" localonly -create /Local/Target/Users/YOURUSERNAME UserShell /bin/bash
## dscl -f "/var/db/dslocal/nodes/Default" localonly -create /Local/Target/Users/YOURUSERNAME RealName "${2}"
## dscl -f "/var/db/dslocal/nodes/Default" localonly -create /Local/Target/Users/YOURUSERNAME PrimaryGroupID 20
## dscl -f "/var/db/dslocal/nodes/Default" localonly -create /Local/Target/Users/YOURUSERNAME UniqueID ${3}
## dscl -f "/var/db/dslocal/nodes/Default" localonly -create /Local/Target/Users/YOURUSERNAME NFSHomeDirectory "/Users/YOURUSERNAME"
## dscl -f "/var/db/dslocal/nodes/Default" localonly -create /Local/Target/Users/YOURUSERNAME Picture "YOURUSERPIC"
## dscl -f "/var/db/dslocal/nodes/Default" localonly -create /Local/Target/Users/YOURUSERNAME IsHidden 0
## dscl -f "/var/db/dslocal/nodes/Default" localonly -passwd /Local/Target/Users/YOURUSERNAME cleartextpassword
## # or write the stored hash instead
## # defaults write "/var/db/dslocal/nodes/Default/Users/YOURUSERNAME.plist" ShadowHashData "${ShadowHashData}"
## dscacheutil -flushcache
## # admin access (optional)
## # dscl -f "/var/db/dslocal/nodes/Default" localonly -append /Local/Target/Groups/admin GroupMembership YOURUSERNAME
## # auto login (optional)
## # defaults write /Library/Preferences/com.apple.loginwindow.plist autoLoginUser -string "YOURUSERNAME"
## # Add "/etc/kcpassword"
