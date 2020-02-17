set nocp
set ai
set nu
set autoread

" Use spaces no tabs
set expandtab
set smarttab
set shiftwidth=2
set tabstop=2
set hidden
set nowrap
set cursorline

" Show the command you're typing
set showcmd

" Open new split panes to right and bottom, which feels more natural than
" Vim's default:
set splitbelow
set splitright

set ruler
set backupdir=/tmp
set directory=/tmp

" no bell of any kind
set vb t_vb=

" incremental search
set incsearch
set nohlsearch

let loaded_matchparen = 1

" look for tags up the dir hierarchy
set tags=tags;/

" Remap jj to Escape
inoremap jj <Esc>
inoremap ,, =>
inoremap ,. ->
nmap g/ :Ex<CR>
nmap g' :ToggleBufExplorer<CR>

" PageUp and PageDown
" Shift-Space and Space
map _ <PageUp>
map <Space> <PageDown>

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Syntax highlight
filetype plugin on
syntax on

map to :tabnew<CR>

" Make vim read external changes on focus and buffer change
au FocusGained,BufEnter * :checktime
