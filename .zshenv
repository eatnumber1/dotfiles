# Early fpath setup in order to find helper functions used in this file.
declare -U fpath
fpath+=( $HOME/.zsh/functions )

autoload -U is_osx source_if_exists is-callable export_or_warn

source_if_exists $HOME/.zshenv.local

() {
  emulate -L zsh
  setopt function_argzero no_unset warn_create_global
  #setopt xtrace

  typeset -gU cdpath mailpath manpath path pythonpath pkg_config_path
  typeset -gUT INFOPATH infopath
  typeset -gUT PYTHONPATH pythonpath
  typeset -gUT PKG_CONFIG_PATH pkg_config_path
  typeset -x PATH MANPATH INFOPATH PYTHONPATH PKG_CONFIG_PATH

  if is_osx; then
    typeset -gUT DYLD_LIBRARY_PATH dyld_library_path
    typeset -x DYLD_LIBRARY_PATH
  fi

  # Set the list of directories that info searches for manuals.
  infopath=(
    /usr/local/share/info
    /usr/share/info
    $infopath
  )

  if is_osx && [[ -f /usr/libexec/path_helper ]]; then
    local helper_output
    if helper_output="$(/usr/libexec/path_helper -s)"; then
      emulate -R sh -c "$helper_output"
    fi
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
  if is_osx; then
    # On OSX, the man binary has custom patches to search xcode paths for man
    # pages, but only when there is an empty element in the manpath.
    # https://gist.github.com/yiding/11270916
    manpath+=( "" )
  fi

  fpath=(
    $HOME/.zsh.local/functions
    $HOME/.zsh/functions
    "${fpath[@]}"
  )

  if [[ -v LANG && -z "$LANG" ]]; then
    export LANG="en_US.UTF-8"
    local locale_output
    if locale_output="$(locale)"; then
      emulate -R sh -c "$locale_output"
    fi
  fi

  # Some /etc/zsh/zshrc files call compinit. Skip it. We unset it later in
  # .zshrc.
  if [[ -o interactive ]]; then
    typeset -g skip_global_compinit=1
  fi

  if is-callable ruby && is-callable gem; then
    local ruby_output
    if ruby_output="$(ruby -r rubygems -e 'puts Gem.user_dir')"; then
      declare -gx GEM_HOME
      GEM_HOME="$ruby_output"
      path=( "$GEM_HOME/bin" "${path[@]}" )
    fi
  fi

  if [[ -d $HOME/.npm-packages ]]; then
    declare -g NPM_PACKAGES="$HOME/.npm-packages"
    path=( $NPM_PACKAGES/bin $path )
    manpath=( $NPM_PACKAGES/share/man "${manpath[@]}" )
  fi

  if [[ -d $HOME/.local ]]; then
    path=( $HOME/.local/bin "${path[@]}" )
    manpath=( $HOME/.local/share/man "${manpath[@]}" )
  fi

  if [[ -d $HOME/bin ]]; then
    path=( $HOME/bin "${path[@]}" )
  fi

  if is-callable vim; then
    declare -gx EDITOR=vim
    declare -gx VISUAL=vim
  else
    echo "vim not found in path" >&2
  fi

  if is-callable less; then
    declare -gx PAGER=less
  else
    echo "less not found in path" >&2
  fi
}

zmodload -F zsh/parameter +p:functions
if (( $+functions[zshenv_post_hook] )); then
  zshenv_post_hook
  unfunction zshenv_post_hook
fi

() {
  autoload is_osx
  local var launchctl_val local_val
  local -a launchctl_val_a local_val_a
  local -a missing_from_local missing_from_launchctl

  is_osx || return 0
  [[ -o interactive ]] || return 0

  for var in PATH MANPATH; do
    launchctl_val="$(launchctl getenv "$var")" || continue
    # Convert the ':' delimited string to an array.
    launchctl_val_a=( "${(@s/:/)launchctl_val}" )
    # Capture the value of the local scalar variable
    local_val="${(P)var}"
    # Convert the ':' delimited string to an array.
    local_val_a=( "${(@s/:/)local_val}" )
    # Compute local - launchctl
    missing_from_local=( "${(@)local_val_a:|launchctl_val_a}" )
    # Compute launchctl - local
    missing_from_launchctl=( "${(@)launchctl_val_a:|local_val_a}" )

    if [[ ${#missing_from_local} -ne 0 || ${#missing_from_launchctl} -ne 0 ]]; then
      echo "Warning: Launchd environment variable $var does not match the current environment." >&2
      if [[ ${#missing_from_launchctl} -ne 0 ]]; then
        echo "The current environment contains the following which launchctl does not:" >&2
        printf "\t'%s'\n" "${missing_from_launchctl[@]}" >&2
      fi
      if [[ ${#missing_from_local} -ne 0 ]]; then
        echo "The launchctl environment contains the following which the current one does not:" >&2
        printf "\t'%s'\n" "${missing_from_local[@]}" >&2
      fi
    fi
  done
}

# On GMac (and maybe all of OSX), /etc/zprofile runs path_helper(8).
# path_helper then moves the system directories in front of anything that is
# set here. Therefore, to work around this we save the path and manpath and
# correct it in .zprofile.
if is_osx && [[ -f /etc/zprofile ]]; then
  typeset -a saved_path saved_manpath
  saved_path=( "${path[@]}" )
  saved_manpath=( "${manpath[@]}" )
fi
