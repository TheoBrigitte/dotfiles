" Vimrc for Drupal programming
"
" Features list:
" Go to file        Ctrl-p
" Go to symbol      Ctrl-m
" Tree view         Ctrl-l
" Buffer view       Ctrl-o
" Find in files     Ctrl-i
"
" Auto-ident        native
" Syntax check      plugin:syntastic
" Auto-completion   ...
" Find results tree ...
" Replace in files  ...
" Debug             ...
" Breakpoints list  ...
" Structure list    ...
" Refactor          ...
" Status bar        ...

" [ Colors ]
"
set t_Co=256
"colorscheme desert

" [ Plugins ]
"
" Pathogen : runtimepath manager
" execute pathogen#infect()

" Indent
"
let g:indentLine_color_term = 239
let g:indentLine_char = '¦'

" CtrlP : Go to file
"set runtimepath^=~/.vim/bundle/ctrlp.vim
"let g:ctrlp_follow_symlinks = 1
"let g:ctrlp_dotfiles = 0
"let g:ctrlp_working_path_mode = 0

" Unite
"call unite#filters#matcher_default#use(['matcher_fuzzy'])
"call unite#filters#sorter_default#use(['sorter_rank'])
"call unite#custom#source('file_rec/async','sorters','sorter_rank')

" [ Settings ]
"
"set list
"set nocompatible
set mouse=a
set number
set ruler
set incsearch
set ignorecase
set smartcase
set hlsearch
set showcmd
"set colorcolumn=80
"
" Ident
set expandtab
set shiftwidth=2
set softtabstop=2
set list listchars=tab:--,trail:.,extends:>,precedes:<
"highlight ColorColumn ctermbg=DarkGray guibg=Gray14
syntax on
filetype plugin indent on
set autoindent
set smartindent
"set background=dark
set encoding=utf8
set ffs=unix,dos,mac
set nobackup
set nowb
set noswapfile

" [ Mapping ]
"
"nnoremap <silent> <esc> :nohlsearch<CR>
"nmap <C-s> :e#<CR>
"nnoremap <C-n> :bnext<CR>
"nnoremap <C-p> :bprev<CR>
"nnoremap <C-o> :CtrlPBuffer<CR>
"nnoremap <C-m> :CtrlPTag<CR>
"nnoremap <C-k> :exe "tag ". expand("<cword>")<CR>
"nnoremap <C-l> :NERDTreeToggle<CR>
"nnoremap <C-i> :Unite grep:.<CR>

"nnoremap <C-p> :Unite file_rec/async<cr>
nmap j gj
nmap k gk


" [ Tags ]
"
""set tags=./tags;/
