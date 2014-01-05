set tabstop=4
set shiftwidth=4
syntax on
set mouse=a
set autoindent
set smartindent
filetype plugin indent on
colorscheme peachpuff
set incsearch
set wildmenu
set hidden
set laststatus=2
"set noshowmode
set pastetoggle=<F10>

let &titlestring = expand("%:t")
if &term == "screen"
	set t_ts=k
	set t_fs=\
endif

if &term == "screen" || &term == "xterm" || &term == "rxvt-unicode"
	set title
endif

if &term !=# "linux"
	set list listchars=tab:\➜\ ,trail:·,nbsp:-
	"set list listchars=tab:│…,trail:·,nbsp:-
endif

function! s:insert_gates()
	let gatename = substitute(toupper(expand("%:t")), "\\.", "_", "g")
	execute "normal! i#ifndef " . gatename
	execute "normal! o#define " . gatename
	execute "normal! Go#endif"
	normal! kk
endfunction

autocmd BufNewFile *.h call <SID>insert_gates()
au FileType python setl tabstop=4
