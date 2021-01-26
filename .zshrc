# We may have set this to skip global compinit in /etc/zsh/zshrc. Unset it here
# to not clutter the environment.
unset skip_global_compinit

source_if_exists $HOME/.zshrc.local

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Source Prezto.
source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"

zmodload -F zsh/parameter +p:commands
autoload -U is-callable

() {
  emulate -L zsh
  setopt function_argzero no_unset warn_create_global
  #setopt xtrace

  if is-callable keychain; then
    local -a keychain
    keychain=( keychain --quiet --inherit any --eval )
    local keychain_output
    if [[ -f "$HOME/.ssh/id_rsa" ]]; then
      keychain+=( "$HOME/.ssh/id_rsa" )
    fi
    if keychain_output="$($keychain)"; then
      emulate -R sh -c "$keychain_output"
    fi
  fi

  # Undo some prezto zsh aliases.
  # aliases which disable spelling correction or globbing, which I don't like
  unalias cp ln mkdir mv rm scp du rsync
  # ls helpers that I don't like
  unalias l ll lr la lm lx lk lt lc lu sl
  # aliases that I just don't care to learn
  unalias get

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

  if is-callable mvim; then
    if ! is-callable gvim; then
      alias gvim="mvim"
    fi
  elif is-callable gvim; then
    alias mvim="gvim"
  fi

  if ! pstree -V &> /dev/null; then
    alias pstree="pstree -g3"
  fi

  # Set the default Less options.
  export LESS="-F -X -i -M -R -S -w -z-4 -a"

  # Set the Less input preprocessor.
  autoload -U lesspipe
  lesspipe -x

  if is_osx; then
    declare -gx BROWSER='open'
  fi

  is-callable slrn && declare -gx NNTPSERVER="snews://news.csh.rit.edu"

  if (( $+commands[bwm-ng] )) {
    function bwm-ng {
      if [[ $# -eq 0 ]] {
        command bwm-ng -u bits -d
      } else {
        command bwm-ng "$@"
      }
    }
  }

  autoload -U trim
  autoload -U mand

  autoload init-run-help
  init-run-help

  declare -gx BASE16_SHELL="$HOME/.config/base16-shell"
}

autoload -U prio

# Gotta set options outside the function due to local_options.
setopt BG_NICE HUP CHECK_JOBS TYPESET_SILENT HIST_FCNTL_LOCK RM_STAR_SILENT
setopt INC_APPEND_HISTORY_TIME
autoload -U is-at-least
is-at-least 4.3.11 && setopt HASH_EXECUTABLES_ONLY
unsetopt CLOBBER SHARE_HISTORY AUTO_RESUME COMPLETE_IN_WORD

zmodload -F zsh/parameter +p:functions
if (( $+functions[zshrc_post_hook] )); then
  zshrc_post_hook
  unfunction zshrc_post_hook
fi

() {
  autoload is_osx
  is_osx || return 0
  local elem
  # Emit a warning if there's no empty element in manpath.
  for elem in "${manpath[@]}"; do
    [[ -z "$elem" ]] && return
  done
  # On OSX, the man binary has custom patches to search xcode paths for man
  # pages, but only when there is an empty element in the manpath.
  # https://gist.github.com/yiding/11270916
  echo "Warning: No empty element found in manpath. XCode man pages will not be available." >&2
}
