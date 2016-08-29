#!/bin/bash
# https://github.com/cgerke/dotfiles

# Help
if [ $# -lt 1 ];  then
    dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    source "${dir}/help.sh"
	exit
fi

shopt -s nocasematch
case $1 in
  ## -h http web server
  m|-m)
  sleep 1 && open "http://localhost:4004/" &
  python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "4004";
  ;;
  ## -j jekyll web server
  j|-j)
    gem list | grep github-pages
    if [ $? == 0 ]; then
      sudo gem install github-pages
      sleep 1 && open "http://127.0.0.1:4000/" &
      jekyll serve
    fi
  ;;
  ## -p php web server
  p|-p)
    sleep 1 && open "http://$(ipconfig getifaddr en1):4004/" &
    php -S "$(ipconfig getifaddr en1):4004";
  ;;
esac
