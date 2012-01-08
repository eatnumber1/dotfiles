let s:uname = system("uname -o")
" Strip off the trailing newline
let s:uname = strpart(s:uname, 0, strlen(s:uname) - 1)

set go-=T go-=r go-=b go-=L
set bg=dark
if &background == "dark"
	hi normal guibg=black
endif

if has("gui_macvim")
	set guifont=Terminus\ Medium:h14
else
	set go-=m go-=e
	set guifont=Terminus\ Medium\ 12
endif

set number
set listchars=nbsp:.,eol:$,tab:>-,trail:~,extends:>,precedes:<
set list
hi NonText guifg=#262626
hi SpecialKey guifg=#262626
