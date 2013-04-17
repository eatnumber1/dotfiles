#
# Defines environment variables.
#

() {
	local ZSHENV_LOCAL="$HOME/.zshenv.local"
	[[ -f "$ZSHENV_LOCAL" ]] && source "$ZSHENV_LOCAL"
}

() {
	emulate -L zsh
	setopt function_argzero err_return no_unset warn_create_global
	#setopt xtrace
	# We set 0 to RANDOM here to prevent name clashes since an anonymous
	# function is always called (anon)
	local 0="$0_$RANDOM"

	{
		#
		# Paths
		#
		typeset -gU cdpath fpath mailpath manpath path pythonpath
		typeset -gUT INFOPATH infopath
		typeset -gUT PYTHONPATH pythonpath
		typeset -x PATH MANPATH INFOPATH

		# Set the the list of directories that cd searches.
		# cdpath=(
		# 	$cdpath
		# )

		# Set the list of directories that info searches for manuals.
		infopath=(
			/usr/local/share/info
			/usr/share/info
			$infopath
		)

		# Set the list of directories that man searches for manuals.
		manpath=(
			/usr/local/share/man
			/usr/share/man
			$manpath
		)

		local path_file
		for path_file in /etc/manpaths.d/*(.N); do
			manpath+=($(<$path_file))
		done

		# Set the list of directories that Zsh searches for programs.
		path=(
			$HOME/.rbenv/bin
			/usr/local/{bin,sbin}
			/usr/{bin,sbin}
			/{bin,sbin}
			$path
		)

		for path_file in /etc/paths.d/*(.N); do
		  path+=($(<$path_file))
		done

		fpath=(
			$HOME/.zsh.local/functions
			$HOME/.zsh/functions
			$fpath
		)

		#
		# Language
		#
		if ! (( $+LANG )) || [[ -z "$LANG" ]]; then
			export LC_ALL="en_US.UTF-8"
			emulate -R sh -c "$(locale)"
		fi

		if (( $+commands[rbenv] )); then
			eval "$(rbenv init -)"
		fi

		path=( $HOME/bin $path )

		# Some /etc/zsh/zshrc files call compinit. Skip it.
		if [[ -o interactive ]]; then
			typeset -g skip_global_compinit=1
		fi

		function $0_trim_nonexistant_from {
			local a
			for a in "$@"; do
				integer i
				for (( i=1; i<=${(P)#a}; i++ )); do
					if [[ ! -d ${(P)${a}[i]} ]]; then
						autoload -U is-at-least
						if is-at-least 4.3.11; then
							eval "${(q-)a}[${i}]=()"
						else
							eval "${(q)a}[${i}]=()"
						fi
					fi
				done
			done
		}
		$0_trim_nonexistant_from path fpath manpath infopath
	} always {
		unfunction -m "$0_*"
	}
}

zmodload -F zsh/parameter +p:functions
if (( $+functions[zshenv_post_hook] )); then
	zshenv_post_hook
	unfunction zshenv_post_hook
fi

# vim:tw=80
