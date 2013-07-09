" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" Pathogen stuff
runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()
Helptags

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

"set nobackup		" don't keep a backup file
set history=50		" keep 50 lines of command line history
set ruler			" show the cursor position all the time
set showcmd			" display incomplete commands
set incsearch		" do incremental searching
set vb t_vb=""		" turn off beeping
"set autowrite
"set textwidth=80
set modeline modelines=5
set nofoldenable
set cursorline
set tabstop=4 shiftwidth=4 softtabstop=4
set spellfile=~/.vim/spellfile.en.add
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*
set wildmode=longest,list,full

if has('statusline')
	set laststatus=2

	set statusline=%<%f\                     " Filename
	set statusline+=%w%h%m%r                 " Options
	"set statusline+=%{fugitive#statusline()} " Git Hotness
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

color inkpot

" Enable file type detection.
" Use the default filetype settings, so that mail gets 'tw' set to 72,
" 'cindent' is on in C files, etc.
" Also load indent files, to automatically do language-dependent indenting.
filetype plugin indent on

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

au BufRead,BufNewFile Gemfile,*.ru,*.rb,*.yml setl tabstop=2 softtabstop=2 shiftwidth=2 expandtab
au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl setf glsl

let g:liquid_highlight_types = ["c", "dot"]

let g:ctrlp_user_command = {
	\ 'types': {
		\ 1: ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others'],
		\ 2: ['.hg', 'hg --cwd %s locate -I .'],
	\ },
	\ 'fallback': 'find %s -type f'
\ }

let g:clang_use_library = 1

" Press Space to turn off highlighting and clear any message already
" displayed.
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

let s:localrc = expand("~/.vimrc.local")
if filereadable(s:localrc)
	execute "source " . s:localrc
endif
