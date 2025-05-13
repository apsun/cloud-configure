set encoding=utf-8
scriptencoding utf-8

" Indent with spaces, smart tab
set expandtab
set shiftwidth=4
set softtabstop=4
set autoindent
set backspace=indent,eol,start

" Hybrid line numbers
set number
" set relativenumber

" Fix escape delay
set timeoutlen=1000 ttimeoutlen=0

" Disable matching brace jumping
set noshowmatch

" Enable mouse cursor movement
if has("mouse")
    set mouse=a
endif

" Enable case insensitive search
set ignorecase
set smartcase

" Disable backup/swap files
set nobackup
set nowritebackup
set noswapfile

" Use system clipboard
set clipboard=unnamedplus

" File type detection
filetype on
filetype plugin on
filetype indent on

" Hard tabs on Makefiles and Go code
autocmd FileType make set noexpandtab shiftwidth=4 tabstop=4
autocmd FileType go set noexpandtab shiftwidth=4 tabstop=4

" Color scheme
syntax enable

" Status line
set laststatus=2
set statusline=
set statusline+=%F
set statusline+=%M
set statusline+=%=
set statusline+=line\ %l
set statusline+=,\ 
set statusline+=col\ %c
