PATH=/opt/dotfiles/.bin:$PATH

for file in ~/.{bash_prompt,exports,aliases,functions}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;
