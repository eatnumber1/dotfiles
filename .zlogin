source_if_exists $HOME/.zlogin.local

zstyle -t ':prezto:module:zcompile' enabled
case $? in
0|2)
  # Execute code that does not affect the current session in the background.
  {
    autoload -U zrecompile
    local ZDOTDIR="${ZDOTDIR:-$HOME}"
    zrecompile -q -p \
      -M "$ZDOTDIR"/.zcompdump -- \
      -R "$ZDOTDIR"/.zshrc -- \
      -R "$ZDOTDIR"/.zpreztorc -- \
      -R "$ZDOTDIR"/.zshenv

    # Set environment variables for launchd processes.
    if is_osx; then
      for env_var in PATH MANPATH; do
        launchctl setenv "$env_var" "${(P)env_var}"
      done
    fi
  } &!
esac

zmodload -F zsh/parameter +p:commands


# Execute code only if STDERR is bound to a TTY.
if [[ -o INTERACTIVE && -t 2 ]] && (( $+commands[fortune] )); then
  # Print a random, hopefully interesting, adage.
  fortune -a
  print
fi

zmodload -F zsh/parameter +p:functions
if (( $+functions[zlogin_post_hook] )); then
  zlogin_post_hook
  unfunction zlogin_post_hook
fi
