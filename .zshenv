#
# Defines environment variables.
#

# Global globals are loaded globally.
zmodload -F zsh/parameter +p:commands

() {
  local ZSHENV_LOCAL="$HOME/.zshenv.local"
  if [[ -f "$ZSHENV_LOCAL" ]]; then
    source "$ZSHENV_LOCAL"
  fi
}

() {
  emulate -L zsh
  setopt function_argzero err_return no_unset warn_create_global
  #setopt xtrace

  typeset -gU cdpath fpath mailpath manpath path pythonpath
  typeset -gUT INFOPATH infopath
  typeset -gUT PYTHONPATH pythonpath
  typeset -x PATH MANPATH INFOPATH PYTHONPATH

  if [[ $OSTYPE == darwin* ]]; then
    typeset -gUT DYLD_LIBRARY_PATH dyld_library_path
    typeset -x DYLD_LIBRARY_PATH
  fi

  # Set the list of directories that info searches for manuals.
  infopath=(
    /usr/local/share/info
    /usr/share/info
    $infopath
  )

  if [[ $OSTYPE == darwin* && -f /usr/libexec/path_helper ]]; then
    eval "$(/usr/libexec/path_helper -s)"
  fi

  path+=(
    /usr/local/{bin,sbin}
    /usr/{bin,sbin}
    /{bin,sbin}
  )

  manpath+=(
    /usr/local/share/man
    /usr/share/man
  )

  fpath=(
    $HOME/.zsh.local/functions
    $HOME/.zsh/functions
    $fpath
  )

  if ! (( $+LANG )) || [[ -z "$LANG" ]]; then
    export LC_ALL="en_US.UTF-8"
    emulate -R sh -c "$(locale)"
  fi

  path=( $HOME/.rbenv/bin $path )
  if (( $+commands[rbenv] )); then
    # TODO: This is inflexible
    [[ -d $HOME/.rbenv/shims ]] && path_move_to_front path $HOME/.rbenv/shims || :
    eval "$(rbenv init -)"
  fi

  path=( $HOME/bin $path )

  # Some /etc/zsh/zshrc files call compinit. Skip it.
  if [[ -o interactive ]]; then
    typeset -g skip_global_compinit=1
  fi

  local ruby="${ruby:-ruby}"
  local gem="${gem:-gem}"
  if (( $+commands[$ruby] && $+commands[$gem] )); then
    path+=( "$($ruby -rubygems -e 'puts Gem.user_dir')/bin" )
  fi
} || :

zmodload -F zsh/parameter +p:functions
if (( $+functions[zshenv_post_hook] )); then
  zshenv_post_hook
  unfunction zshenv_post_hook
fi

# On GMac (and maybe all of OSX), /etc/zprofile runs path_helper(8).
# path_helper then moves the system directories in front of anything that is
# set here. Therefore, to work around this we save the path and manpath and
# correct it in .zprofile.
if [[ $OSTYPE == darwin* && -f /etc/zprofile ]]; then
  typeset -a saved_path saved_manpath
  saved_path=( $path )
  saved_manpath=( $manpath )
fi

# vim:tw=80
