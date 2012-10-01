## create a zkbd compatible hash;
## to add other keys to this hash, see: man 5 terminfo
#typeset -A key
#
#key[Home]=${terminfo[khome]}
#key[End]=${terminfo[kend]}
#key[Insert]=${terminfo[kich1]}
#key[Delete]=${terminfo[kdch1]}
#key[Up]=${terminfo[kcuu1]}
#key[Down]=${terminfo[kcud1]}
#key[Left]=${terminfo[kcub1]}
#key[Right]=${terminfo[kcuf1]}
#key[PageUp]=${terminfo[kpp]}
#key[PageDown]=${terminfo[knp]}
#
#for k in ${(k)key} ; do
#    # $terminfo[] entries are weird in ncurses application mode...
#    [[ ${key[$k]} == $'\eO'* ]] && key[$k]=${key[$k]/O/[}
#done
#unset k
#
## setup key accordingly
#[[ -n "${key[Home]}"    ]]  && bindkey  "${key[Home]}"    beginning-of-line
#[[ -n "${key[End]}"     ]]  && bindkey  "${key[End]}"     end-of-line
#[[ -n "${key[Insert]}"  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
#[[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
#[[ -n "${key[Up]}"      ]]  && bindkey  "${key[Up]}"      up-line-or-history
#[[ -n "${key[Down]}"    ]]  && bindkey  "${key[Down]}"    down-line-or-history
#[[ -n "${key[Left]}"    ]]  && bindkey  "${key[Left]}"    backward-char
#[[ -n "${key[Right]}"   ]]  && bindkey  "${key[Right]}"   forward-char
#
## Turn off username completion.
#zstyle -e ':completion:*:*:*' users 'reply=()'
#
## Turn off derpy zsh features
#setopt noalways_to_end
#setopt nocomplete_in_word
#setopt noauto_name_dirs
#setopt noshare_history
#setopt noautocd

alias l="ls"
alias sl="ls"
alias s="ls"

[[ -x ${commands[cygstart]} ]] && alias open="cygstart"

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

alias run-help >/dev/null && unalias run-help
HELPDIR="$HOME/.zsh/help"
autoload run-help

setopt BG_NICE
setopt HUP
setopt CHECK_JOBS
