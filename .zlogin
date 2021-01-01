source_if_exists $HOME/.zlogin.local

# Execute code that does not affect the current session in the background.
{
  autoload -U zrecompile
  local ZDOTDIR="${ZDOTDIR:-$HOME}"
  zrecompile -q -p \
    "$ZDOTDIR"/.zcompdump -- \
    "$ZDOTDIR"/.zshrc -- \
    "$ZDOTDIR"/.zpreztorc -- \
    "$ZDOTDIR"/.zshenv -- \
    "${XDG_CACHE_HOME:-$HOME/.cache}/prezto/zcompdump"
} &!

# Set environment variables for launchd processes.
# https://stackoverflow.com/a/3756686/2562787
autoload -U is_osx
if is_osx; then
  launchctl setenv PATH "$PATH"
  launchctl setenv MANPATH "$MANPATH"
fi

zmodload -F zsh/parameter +p:functions
if (( $+functions[zlogin_post_hook] )); then
  zlogin_post_hook
  unfunction zlogin_post_hook
fi
