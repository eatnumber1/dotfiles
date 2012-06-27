" An example for a vimrc file.

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
	finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set nobackup		" don't keep a backup file
set history=50		" keep 50 lines of command line history
set ruler			" show the cursor position all the time
set showcmd			" display incomplete commands
set incsearch		" do incremental searching
set vb t_vb=""		" turn off beeping

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
	syntax on
	set hlsearch
endif

" Pathogen stuff
runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()
Helptags

color inkpot

set tabstop=4 shiftwidth=4 softtabstop=4
set spellfile=~/.vim/spellfile.en.add

let g:liquid_highlight_types = ["c", "dot"]

" Only do this part when compiled with support for autocommands.
if has("autocmd")

	" Enable file type detection.
	" Use the default filetype settings, so that mail gets 'tw' set to 72,
	" 'cindent' is on in C files, etc.
	" Also load indent files, to automatically do language-dependent indenting.
	filetype plugin indent on

	" Put these in an autocmd group, so that we can delete them easily.
	augroup vimrcEx
		au!

		" For all text files set 'textwidth' to 78 characters.
		autocmd FileType text setlocal textwidth=80

		" When editing a file, always jump to the last known cursor position.
		" Don't do it when the position is invalid or when inside an event handler
		" (happens when dropping a file on gvim).
		autocmd BufReadPost *
					\ if line("'\"") > 0 && line("'\"") <= line("$") |
					\   exe "normal g`\"" |
					\ endif

	augroup END

	augroup Markdown
		au BufRead,BufNewFile *.mkd,*.markdown,*.md,*.mkdn setf mkd
	"	set ai formatoptions=tcroqn2 comments=n:&gt;
		au BufRead,BufNewFile *.mkd,*.markdown,*.md,*.mkdn setlocal spell
	augroup END

	augroup Ruby
		au BufRead,BufNewFile Gemfile *.ru *.rb setl tabstop=2 softtabstop=2 shiftwidth=2 expandtab
	augroup END
else

	"  set autoindent		" always set autoindenting on

endif " has("autocmd")

set autowrite
"set textwidth=80
set modeline modelines=5

" Press Space to turn off highlighting and clear any message already
" displayed.
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

set wildmode=longest,list,full

let s:localrc = expand("~/.vimrc-local")
if filereadable(s:localrc)
	execute "source " . s:localrc
endif

set nofoldenable
