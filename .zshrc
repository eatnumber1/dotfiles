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
		autoload -U unalias unfunction

		if is-callable keychain; then
			emulate -R sh -c "$(keychain --quiet --eval --inherit any-once)"
			if [[ -f "$HOME/.ssh/id_rsa" ]]; then
				keychain --quiet "$HOME/.ssh/id_rsa"
			fi
		fi

		# Undo some prezto zsh aliases.
		unalias cp ln mkdir mv rm l ll lr la lm lx lk lt lc lu sl scp get du top rsync
		unfunction kill diff

		unalias run-help
		typeset -g HELPDIR="$HOME/.zsh/help"
		autoload run-help

		alias cp='nocorrect cp'
		alias ln='nocorrect ln'
		alias mkdir='nocorrect mkdir'
		alias rm='nocorrect rm'
		alias df='(){ if [[ $# -eq 0 ]] { df -h } else { df "$@" } }'

		if is-callable cygstart; then
			alias open="cygstart"
		fi

		alias l="ls"
		alias sl="ls"
		alias s="ls"

		if (( $+commands[mvim] )); then
			if (( ! $+commands[gvim] )); then
				alias gvim="mvim"
			fi
		elif (( $+commands[gvim] )); then
			alias mvim="gvim"
		fi

		if ! pstree -V &> /dev/null; then
			alias pstree="pstree -g3"
		fi

		alias trim='(){ "$@" | cut -c1-$COLUMNS }'

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

		is-callable slrn && export NNTPSERVER="snews://news.csh.rit.edu"

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
				if is-callable $cmd; then
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

		local rvm_script=$HOME/.rvm/scripts/rvm
		autoload -U bash_source
		[[ -f $rvm_script ]] && bash_source $rvm_script

		zmodload -F zsh/stat +b:zstat
		typeset -gi LAST_REHASH
		function rehash-if-needed {
			emulate -L zsh
			setopt err_return warn_create_global
			local rehash_trigger=${TMPDIR:-/tmp}/zsh-needs-rehash-$USERNAME
			if [[ -f $rehash_trigger ]]; then
				typeset -A stats
				zstat -H stats +mtime $rehash_trigger
				if [[ $LAST_REHASH -lt $stats[mtime] ]]; then
					hash -r
					LAST_REHASH=$stats[mtime]
				fi
			fi
		}
		add-zsh-hook preexec rehash-if-needed

		function exec-and-trigger-rehash {
			emulate -L zsh
			setopt err_return warn_create_global
			local rehash_trigger=${TMPDIR:-/tmp}/zsh-needs-rehash-$USERNAME
			integer code
			local cmd=$1
			shift
			command $cmd "$@" || code=$?
			builtin echo -n > $rehash_trigger
			return $code
		}

		function $0_wrap_if_found {
			local cmd
			for cmd in "$@"; do
				if is-callable $cmd; then
					function $cmd {
						setopt local_options function_argzero
						exec-and-trigger-rehash $0 "$@"
					}
				fi
			done
		}
		$0_wrap_if_found brew dpkg apt-get aptitude yum rpm

		function git {
			if [[ $1 == grep ]]; then
				noglob command git "$@"
			else
				command git "$@"
			fi
		}

		local p
		for p in /usr/lib{64,}/ccache; do
			# Use ccache if available.
			if [[ -d $p ]]; then
				path=( $p $path )

				# Use distcc if available.
				if [[ -f /etc/distcc/hosts ]]; then
					typeset -gx CCACHE_PREFIX="distcc"
					typeset -gx CCACHE_COMPRESS=1
				fi

				break
			fi
		done

		if (( $+commands[bwm-ng] )) {
			function bwm-ng {
				if [[ $# -eq 0 ]] {
					command bwm-ng -u bits -d
				} else {
					command bwm-ng "$@"
				}
			}
		}
	} always {
		builtin unfunction unfunction
		unfunction unalias
		unfunction -m "$0_*"
	}
}

autoload -U prio

# Gotta set these outside the function due to local_options.
setopt BG_NICE HUP CHECK_JOBS TYPESET_SILENT HIST_FCNTL_LOCK
autoload -U is-at-least
is-at-least 4.3.11 && setopt HASH_EXECUTABLES_ONLY
unsetopt CLOBBER SHARE_HISTORY AUTO_RESUME

zmodload -F zsh/parameter +p:functions
if (( $+functions[zshrc_post_hook] )); then
	zshrc_post_hook
	unfunction zshrc_post_hook
fi

true # Set return code
# vim:tw=80
