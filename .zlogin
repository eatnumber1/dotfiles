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

zmodload -F zsh/parameter +p:functions
if (( $+functions[zlogin_post_hook] )); then
  zlogin_post_hook
  unfunction zlogin_post_hook
fi
