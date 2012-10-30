#
# Defines environment variables.
#

() {
	setopt LOCAL_OPTIONS
	setopt FUNCTION_ARGZERO
	setopt ERR_RETURN
	setopt NOUNSET
	#setopt XTRACE
	# We set 0 to RANDOM here to prevent name clashes since an anonymous
	# function is always called (anon)
	local 0="$0_$RANDOM"

	{
		#
		# Browser
		#
		if [[ "$OSTYPE" == darwin* ]]; then
		  export BROWSER='open'
		fi

		#
		# Editors
		#
		function $0_export_or_warn {
			typeset -i argeven
			let "argeven = $# % 2"
			if [[ $argeven -ne 0 ]]; then
				zmodload -F zsh/system +b:syserror
				syserror EINVAL
				return 1
			fi

			typeset -A args
			args=( "$@" )
			local var
			for var in "${(k)args[@]}"; do
				local cmd="$args[$var]"
				if [[ -x ${commands[$cmd]} ]]; then
					export "$var=$cmd"
				else
					echo "$cmd not found in path" >&2
				fi
			done
		}
		$0_export_or_warn \
			EDITOR vim \
			VISUAL vim \
			PAGER less

		#
		# Language
		#
		if ! (( $+LANG )) || [[ -z "$LANG" ]]; then
		  eval "$(locale)"
		fi

		#
		# Less
		#
		# Set the default Less options.
		# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
		# Remove -X and -F (exit if the content fits on one screen) to enable it.
		export LESS='-F -g -i -M -R -S -w -X -z-4'

		# Set the Less input preprocessor.
		if (( $+commands[lesspipe.sh] )); then
		  export LESSOPEN='| /usr/bin/env lesspipe.sh %s 2>&-'
		fi

		#
		# Paths
		#
		typeset -gU cdpath fpath mailpath manpath path
		typeset -gUT INFOPATH infopath
		typeset -x PATH MANPATH INFOPATH

		# Set the the list of directories that cd searches.
		# cdpath=(
		#   $cdpath
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
		  $HOME/bin
		  /usr/local/{bin,sbin}
		  /usr/{bin,sbin}
		  /{bin,sbin}
		  $path
		)

		for path_file in /etc/paths.d/*(.N); do
		  path+=($(<$path_file))
		done

		fpath=(
			$HOME/.zsh-local/functions
			$HOME/.zsh/functions
			$fpath
		)

		#
		# Temporary Files
		#
		if (( $+TMPDIR )) && [[ -d "$TMPDIR" ]]; then
		  export TMPPREFIX="${TMPDIR%/}/zsh"
		  if [[ ! -d "$TMPPREFIX" ]]; then
			mkdir -p "$TMPPREFIX"
		  fi
		fi

		(( $+commands[slrn] )) && export NNTPSERVER="snews://news.csh.rit.edu"


		false
		if (( $+commands[keychain] )); then
			eval "$(keychain --quiet --eval --inherit any-once)"
			if [[ -f "$HOME/.ssh/id_rsa" ]]; then
				keychain --quiet "$HOME/.ssh/id_rsa"
			fi
		fi
	} always {
		unfunction -m "$0_*"
	}
}

# Some /etc/zsh/zshrc files call compinit. Skip it.
typeset skip_global_compinit=1

# vim:tw=80
