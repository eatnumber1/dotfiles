#!/usr/bin/env zsh
emulate -L zsh
setopt err_exit no_unset warn_create_global
#setopt xtrace

ls -l /proc/$$/fd

exec 2>&1

echo "zsh $ZSH_VERSION"

git ls-files -z -- '.zsh*' | while read -rd $'\0' file; do
	[[ $file =~ \.zsh/help/.* ]] && continue
	echo -n "Syntax checking $file... "
	zsh -o no_exec -o no_rcs $file
	echo "OK"
done
