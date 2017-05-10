# PATH bin
if [ -d "/usr/local/bin" ]; then
    export PATH=$PATH:/usr/local/bin
fi

# PATH CocoaDialog
if [ -d "/Applications/CocoaDialog.app/Contents/MacOS" ]; then
    export PATH=$PATH:"/Applications/CocoaDialog.app/Contents/MacOS"
fi

# PATH Munki
if [ -d "/usr/local/munki" ]; then
    export PATH=$PATH:/usr/local/munki
fi

# PATH VirtualBox
if [ -d "/Applications/VirtualBox.app/Contents/MacOS" ]; then
    export PATH=$PATH:"/Applications/VirtualBox.app/Contents/MacOS"
fi

# PATH VMware Fusion
if [ -d "/Applications/VMware Fusion.app/Contents/Library" ]; then
    export PATH=$PATH:"/Applications/VMware Fusion.app/Contents/Library"
fi

# PATH vfuse
if [ -d "/usr/local/vfuse" ]; then
    export PATH=$PATH:"/usr/local/vfuse"
fi

# PATH kickstart
if [ -d "/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources" ]; then
    export PATH=$PATH:"/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources"
fi

# Colour
tput sgr0; # reset
reset=$(tput sgr0);
blue=$(tput setaf 33);
cyan=$(tput setaf 37);
orange=$(tput setaf 166);
red=$(tput setaf 124);
violet=$(tput setaf 61);
white=$(tput setaf 15);
yellow=$(tput setaf 136);

# Exports
export EDITOR='vim';
export HISTSIZE='1024';
export HISTFILESIZE="${HISTSIZE}";
# Omit duplicates and commands that begin with a space from history.
export HISTCONTROL='ignoreboth';
# Highlight section titles in manual pages.
export LESS_TERMCAP_md="${yellow}"
# Don’t clear the screen after quitting a manual page.
export MANPAGER='less -X';

# Source
for dotfile in ~/.{aliases,git-completion}; do
	[ -r "$dotfile" ] && [ -f "$dotfile" ] && source "$dotfile";
done;
unset dotfile;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Homebrew
# _url="https://raw.githubusercontent.com/Homebrew/install/master/install"
# [ ! -f /usr/local/bin/brew ] && /usr/bin/ruby -e "$(curl -fsSL $_url)"
# brew tap caskroom/cask # https://caskroom.github.io/
# brew tap cgerke/formulae

# Functions
function admin_user (){ # add a user to the admin group, requires 1 arg
  [ $# -gt 0 ] && sudo dsmemberutil checkmembership -U "$1" -G admin | grep 'not' && sudo dseditgroup -o edit -a "$1" -t user admin
}

function c (){ # code repos
  cd ~/Google\ Drive/code
}

function cpu(){ # display process type
  system_profiler SPHardwareDataType | grep "Processor Name" | awk '{print $3$4$5$6$7$8$9}'
}

function ci(){ # chef cpe_init
  cd ~/Google\ Drive/code/cookbooks
  sudo chef-client -z -o cpe_init
}

function delete_ds(){ # delete ds_store files
  find . -type f -name '*.DS_Store' -ls -delete
}

function ff(){ # fast find, requires 1 arg
  [ $# -gt 0 ] && find . -name $1
}

function ghr(){ # github repo, requires 1 argument
  [ $# -gt 0 ] && curl -u 'cgerke' https://api.github.com/user/repos -d "{\"name\":\"$1\"}"
}

function h (){ # display function summary (provide the funcname for details)
  if [ $# -eq 0 ]; then
    less ~/.bash_profile | grep function | sed -e 's/(){//' | grep -v '##'
  else
    type $1
  fi
}

function hide(){ # hidden file type `toggle`
  if [ $(defaults read com.apple.finder AppleShowAllFiles) == true ]; then
    defaults write com.apple.finder AppleShowAllFiles false
  else
    defaults write com.apple.finder AppleShowAllFiles true
  fi
  killall Finder
}

function http-server(){ # spin a http server on localhost
  sleep 1 && open "http://localhost:4004/" &
  python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "4004";
}

function ip(){ # display ip addresses
  echo "en0: $(ipconfig getifaddr en0)"
  echo "en1: $(ipconfig getifaddr en1)"
  echo "wan: $(dig +short myip.opendns.com @resolver1.opendns.com)"
}

function jekyll-server(){ # spin a jekyll server on localhost
	gem list | grep github-pages
	if [ $? == 0 ]; then
		sudo gem install github-pages
		sleep 1 && open "http://127.0.0.1:4000/" &
		jekyll serve
	fi
}

function ku(){ # knife cookbook upload, requires 1 argument
  [ $# -gt 0 ] && knife cookbook upload $1
}

function mac(){ # display mac addresses
	echo "en0: $(networksetup -getMACADDRESS en0 | awk '{print $3}' | sed s/://g)"
	echo "en1: $(networksetup -getMACADDRESS en1 | awk '{print $3}' | sed s/://g)"
}

function memory(){ # display system memory
	system_profiler SPHardwareDataType | grep "Memory" | awk '{print $2$3}'
}

function model(){ # display system model
	ioreg -rd1 -c IOPlatformExpertDevice | grep -E model | awk '{print $3}' | sed 's/\<\"//' | sed 's/\"\>//'
}

function mute(){ # mute system volume
	osascript -e "set Volume 0"
}

function php-server(){ # spin a php server on localhost
	sleep 1 && open "http://$(ipconfig getifaddr en1):4004/" &
	php -S "$(ipconfig getifaddr en1):4004";
}

function serial(){ # display system serial
	ioreg -l | grep IOPlatformSerialNumber | awk '{print $4}' | cut -d '"' -f 2
}

function timeserver(){ # display timeserver
  sudo systemsetup -getusingnetworktime
  sudo systemsetup -getnetworktimeserver
}

function timezone(){ # display timezone
	sudo systemsetup -gettimezone
}

function version(){ # display system software version
  sw_vers -productVersion
  sw_vers -buildVersion
}

function vb(){ # working with virtualbox
  vb='/Applications/VirtualBox.app/Contents/MacOS/VBoxManage'
}

git_prompt() {
	local s='';
	local branchName='';

	if [ $(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}") == '0' ]; then # Git repo?
		if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]; then # Git .git?
			git update-index --really-refresh -q &>/dev/null;

			if ! $(git diff --quiet --ignore-submodules --cached); then # Un-committed?
				s+='+';
			fi;

			if ! $(git diff-files --quiet --ignore-submodules --); then # Un-staged?
				s+='!';
			fi;

			if [ -n "$(git ls-files --others --exclude-standard)" ]; then # Un-tracked?
				s+='?';
			fi;

			if $(git rev-parse --verify refs/stash &>/dev/null); then # Stashed?
				s+='$';
			fi;

		fi;

		# Get the short symbolic ref.
		# If HEAD isn’t a symbolic ref, get the short SHA for the latest commit
		# Otherwise, just give up.
		branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
			git rev-parse --short HEAD 2> /dev/null || \
			echo '(unknown)')";

		[ -n "${s}" ] && s="[${s}]";

		echo -e "${1}${branchName}${1}${s}";
	else
		return;
	fi;
}

# Prompt
PS1="\[\033]0;\W\007\]\n"; # base name
PS1+="\[${orange}\]\u "; # username
PS1+="\[${yellow}\]\h "; # host
PS1+="\[${blue}\]\w\n"; # full path
PS1+="\$(git_prompt \"\[${violet}\]\")"; # Git
PS1+="\[${orange}\]\$ \[${reset}\]"; # `$` (and reset color)
export PS1;
PS2="\[${orange}\]→ \[${reset}\]";
export PS2;

SUDO_PS1="\[\033]0;\W\007\]\n"; # base name
SUDO_PS1+="\[${red}\]\u "; # username
SUDO_PS1+="\[${yellow}\]\h "; # host
SUDO_PS1+="\[${blue}\]\w\n"; # full path
SUDO_PS1+="\[${red}\]\$ \[${reset}\]"; # `$` (and reset color)
export SUDO_PS1;
PS2="\[${red}\]→ \[${reset}\]";
export SUDO_PS2;
