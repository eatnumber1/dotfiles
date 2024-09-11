" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

function s:call_if_exists(fn, ...)
  if exists('*' . a:fn)
    call call(a:fn, a:000)
  endif
endfunction

let s:localrc = expand("~/.vimrc.local")
if filereadable(s:localrc)
  execute "source " . s:localrc
endif

" Pathogen stuff
runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()
call s:call_if_exists("Vimrc_pathogen_hook")
Helptags

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=50
set ruler
set showcmd
set incsearch
set vb t_vb=""
set modeline modelines=5
set nofoldenable
set cursorline
set tabstop=2 shiftwidth=2 softtabstop=2 expandtab
set spellfile=~/.vim/spellfile.en.add,~/.vim.google/spellfile.en.add,~/.vim.local/spellfile.en.add
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*
set wildmode=longest,list,full
set tabstop=2 softtabstop=2 shiftwidth=2 expandtab

if has('statusline')
  set laststatus=2

  set statusline=%<%f\                     " Filename
  set statusline+=%w%h%m%r                 " Options
  set statusline+=\ [%{&ff}/%Y]            " Filetype
  set statusline+=\ [%{getcwd()}]          " Current dir
  set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

runtime kitty.vim

if exists('$BASE16_THEME')
    \ && (!exists('g:colors_name') || g:colors_name != 'base16-$BASE16_THEME')
  let base16colorspace=256
  colorscheme base16-$BASE16_THEME
endif
"colorscheme inkpot  " Old color theme

" For all text files set 'textwidth' to 80 characters.
autocmd FileType text setlocal textwidth=80

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal g`\"" |
      \ endif


au BufRead,BufNewFile *.mkd,*.markdown,*.md,*.mkdn setf mkd
au BufRead,BufNewFile *.mkd,*.markdown,*.md,*.mkdn setlocal spell

au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl setf glsl

" Press Space to turn off highlighting and clear any message already
" displayed.
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

set number
set listchars=nbsp:.,eol:$,tab:>-,trail:~,extends:>,precedes:<
set list
hi NonText guifg=#262626 ctermfg=236
hi SpecialKey guifg=#262626 ctermfg=236

let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --hidden
    \ --ignore .git
    \ --ignore .svn
    \ --ignore .hg
    \ --ignore .DS_Store
    \ --ignore "**/*.pyc"
    \ --ignore .git5_specs
    \ --ignore review
    \ -g ""'
let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }

call s:call_if_exists("Vimrc_post_hook")

" Enable file type detection.
" Use the default filetype settings, so that mail gets 'tw' set to 72,
" 'cindent' is on in C files, etc.
" Also load indent files, to automatically do language-dependent indenting.
filetype plugin indent on

autocmd BufRead,BufNewFile *.ebnf setf ebnf

" Allows for correctly reading nsfplay sources.
set fileencodings=ucs-bom,utf-8,default,sjis,latin1

" Turn off mouse support
set mouse-=a
