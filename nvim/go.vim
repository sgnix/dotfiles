set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

" Begin of vim-bundle
" -------------------
call plug#begin('~/.vim/plugged')

Plug 'flazz/vim-colorschemes'
Plug 'mileszs/ack.vim'
Plug 'tpope/vim-fugitive'
Plug 'jlanzarotta/bufexplorer'
Plug 'kien/ctrlp.vim'
Plug 'fatih/vim-go'
Plug 'cespare/vim-toml'
Plug 'preservim/nerdcommenter'

call plug#end()
"------------------------

colo deepsea

source ~/.config/nvim/init/common.vim
source ~/.config/nvim/init/color.vim
source ~/.config/nvim/init/session.vim

let g:go_version_warning = 0

let g:ctrlp_by_filename = 1
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files']
