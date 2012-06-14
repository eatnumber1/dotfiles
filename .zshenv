zmodload -F zsh/system +b:syserror

function path {
	if [[ $# -lt 2 ]]; then
		syserror EINVAL
		return 1
	fi
	typeset cmd="$1"
	shift
	typeset -a directories
	directories=( "$@" )
	local x i d
	if [[ "$cmd" == "remove" ]]; then
		for d in "$directories[@]"; do
			for (( i=1; i<=${#path}; i++ )); do
				[[ "$d" == "$path[$i]" ]] && path[$i]=()
			done
		done
	else
		for (( x=1; x<=${#path}; x++ )); do
			for (( i=1; i<=${#directories}; i++ )); do
				if [[ "$directories[$i]" == "$path[$x]" ]]; then
					path[$x]=()
					let x-=1
				elif [[ ! -d "$directories[$i]" ]]; then
					directories[$i]=()
					let i-=1
				fi
			done
		done
		for d in "$directories[@]"; do
			case "$cmd" in
			prepend)
				path=( "$d" "$path[@]" )
				;;
			append)
				path+=( "$d" )
				;;
			*)
				syserror EINVAL
				return 1
			esac
		done
	fi
}

function export_if_exist {
	typeset -i argeven
	let "argeven = $# % 2"
	if [[ $argeven -ne 0 ]]; then
		syserror EINVAL
		return 1
	fi
	typeset -A args
	args=( "$@" )
	local var
	for var in "${(k)args[@]}"; do
		export "${var}=${args[$var]}"
	done
}

function envvars {
	typeset -g prefix="$HOME/prefix"
	if [[ -d "$prefix" ]]; then
		# TODO: Replace with path_to_array function
		perl5lib=( "${(s/:/)PERL5LIB}" )
		perl5lib+=( "$prefix/lib/perl5" )
		export PERL5LIB="${(j/:/)perl5lib}"

		manpath+=( "$prefix/man" "$prefix/share/man" )
	fi

	path prepend "$HOME/bin" /usr/local/{s,}bin
	path append "/Applications/LyX.app/Contents/MacOS" "/usr/texbin" "$HOME/.cabal/bin" "$prefix/bin"
	[[ -f /etc/debian_version && -d /var/lib/gems ]] && path append /var/lib/gems/*/bin
	path remove "."

	if [[ -x ${commands[vim]} ]]; then
		export EDITOR="vim"
	else
		echo "Vim not found in path" >&2
	fi
	[[ -x ${commands[slrn]} ]] && export NNTPSERVER="snews://news.csh.rit.edu"
	if [[ -x ${commands[brew]} ]]; then
		path append "$(brew --prefix openssl)/bin"
		export_if_exist \
			GEM_HOME "$(brew --cellar)/gems/1.8" \
			NODE_PATH "$(brew --prefix)/lib/node_modules"
		if (( ${+GEM_HOME} )); then
			path append "$GEM_HOME"/bin
		fi
	fi
	export_if_exist \
		M2_HOME "/usr/share/maven" \
		JAVA_HOME "/System/Library/Frameworks/JavaVM.framework/Home"

	fpath=( "$HOME/.zsh/functions" "$fpath[@]" )

	if [[ -x "${commands[xclip]}" ]]; then
		if [[ -z "${commands[pbcopy]}" ]]; then
			alias pbcopy="xclip -in -selection clipboard"
		fi
		if [[ -z "${commands[pbpaste]}" ]]; then
			alias pbpaste="xclip -out -selection clipboard"
		fi
	fi

	if [[ -x "${commands[keychain]}" ]]; then
		eval "$(keychain --quiet --eval --inherit any-once id_rsa)"
	fi
}
envvars
unfunction envvars
