# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="sorin"

# Set to this to use case-sensitive completion
CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(brew github osx lol vi-mode)

typeset -r OS="$(uname -s)"

# Git plugin is SLLOOOWWW on cygwin
if ! [[ "$OS" =~ CYGWIN.* ]]; then
	plugins+=( git )
fi

typeset -r ZSHRC_LOCAL="$HOME/.zshrc-local"
[[ -f "$ZSHRC_LOCAL" ]] && source "$ZSHRC_LOCAL"

source $ZSH/oh-my-zsh.sh

if [[ "$OS" =~ CYGWIN.* ]]; then
	# Disable all built-in git hax
	function git_prompt_info() {}
	function parse_git_dirty() {}
	function git_prompt_ahead() {}
	function git_prompt_short_sha() {}
	function git_prompt_long_sha() {}
	function git_prompt_status() {}
fi

RPROMPT='$(vi_mode_prompt_info)'" $RPS1"

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -A key

key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

for k in ${(k)key} ; do
    # $terminfo[] entries are weird in ncurses application mode...
    [[ ${key[$k]} == $'\eO'* ]] && key[$k]=${key[$k]/O/[}
done
unset k

# setup key accordingly
[[ -n "${key[Home]}"    ]]  && bindkey  "${key[Home]}"    beginning-of-line
[[ -n "${key[End]}"     ]]  && bindkey  "${key[End]}"     end-of-line
[[ -n "${key[Insert]}"  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
[[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
[[ -n "${key[Up]}"      ]]  && bindkey  "${key[Up]}"      up-line-or-history
[[ -n "${key[Down]}"    ]]  && bindkey  "${key[Down]}"    down-line-or-history
[[ -n "${key[Left]}"    ]]  && bindkey  "${key[Left]}"    backward-char
[[ -n "${key[Right]}"   ]]  && bindkey  "${key[Right]}"   forward-char

# Turn off username completion.
zstyle -e ':completion:*:*:*' users 'reply=()'

# Turn off derpy zsh features
setopt noalways_to_end
setopt nocomplete_in_word
setopt noauto_name_dirs
setopt noshare_history
setopt noautocd

alias l="ls"
alias sl="ls"
alias s="ls"
alias psg="ps wwwaux | grep -v grep | grep"

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
	path remove "."

	if [[ -x ${commands[vim]} ]]; then
		export EDITOR="vim"
	else
		echo "Vim not found in path" >&2
	fi
	[[ -x ${commands[slrn]} ]] && export NNTPSERVER="snews://news.csh.rit.edu"
	if [[ -x ${commands[brew]} ]]; then
		path append "$(brew --prefix openssl)/bin"
		export_if_exist GEM_HOME "$(brew --cellar)/gems/1.8"
	fi
	export_if_exist \
		NODE_PATH "/usr/local/lib/node" \
		M2_HOME "/usr/share/maven" \
		JAVA_HOME "/System/Library/Frameworks/JavaVM.framework/Home"

	fpath=( "$HOME/.zsh/functions" "$fpath[@]" )
}
envvars

[[ -x ${commands[cygstart]} ]] && alias open="cygstart"
