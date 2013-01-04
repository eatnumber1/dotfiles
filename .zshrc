unset skip_global_compinit

() {
	local ZSHRC_LOCAL="$HOME/.zshrc.local"
	[[ -f "$ZSHRC_LOCAL" ]] && source "$ZSHRC_LOCAL"
}

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

() {
	emulate -L zsh
	setopt function_argzero err_return no_unset warn_create_global
	# We set 0 to RANDOM here to prevent name clashes since an anonymous
	# function is always called (anon)
	local 0="$0_$RANDOM"
	{
		zmodload -F zsh/parameter +p:commands

		function unalias {
			local a
			zmodload -F zsh/parameter +p:aliases
			for a in "$@"; do
				(( $+aliases[$a] )) && builtin unalias "$a"
			done
		}

		function unfunction {
			local f
			zmodload -F zsh/parameter +p:functions
			for f in "$@"; do
				(( $+functions[$f] )) && builtin unfunction "$f"
			done
		}

		if (( $+commands[keychain] )); then
			eval "$(keychain --quiet --eval --inherit any-once)"
			if [[ -f "$HOME/.ssh/id_rsa" ]]; then
				keychain --quiet "$HOME/.ssh/id_rsa"
			fi
		fi

		# Undo some prezto zsh aliases.
		unalias cp ln mkdir mv rm l ll lr la lm lx lk lt lc lu sl scp get du top rsync
		unfunction kill

		unalias run-help
		typeset -g HELPDIR="$HOME/.zsh/help"
		autoload run-help

		alias cp='nocorrect cp'
		alias ln='nocorrect ln'
		alias mkdir='nocorrect mkdir'
		alias rm='nocorrect rm'

		if (( $+commands[cygstart] )); then
			alias open="cygstart"
		fi

		alias l="ls"
		alias sl="ls"
		alias s="ls"

		if ! pstree -V &> /dev/null; then
			alias pstree="pstree -g3"
		fi

		#
		# Less
		#
		# Set the default Less options.
		export LESS="-F -X -i -M -R -S -w -z-4 -a"

		# Set the Less input preprocessor.
		autoload -U lesspipe
		lesspipe -x

		#
		# Browser
		#
		if [[ "$OSTYPE" == darwin* ]]; then
		  export BROWSER='open'
		fi

		(( $+commands[slrn] )) && export NNTPSERVER="snews://news.csh.rit.edu"

		typeset -gx TRY_HELPERS_HOME="$HOME/Sources/try-helpers"

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
				if (( $+commands[$cmd] )); then
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
	} always {
		builtin unfunction unfunction
		unfunction unalias
		unfunction -m "$0_*"
	}
}

if [[ $OSTYPE == linux* ]]; then
	function mean {
		ionice -c1 -n0 chrt -r 99 nice -n -20 "$@"
	}
fi

# Gotta set these outside the function due to local_options.
setopt bg_nice hup check_jobs clobber typeset_silent
setopt no_share_history no_auto_cd no_auto_pushd

zmodload -F zsh/parameter +p:functions
if (( $+functions[zshrc_post_hook] )); then
	zshrc_post_hook
	unfunction zshrc_post_hook
fi

# vim:tw=80
