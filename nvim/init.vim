set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

call plug#begin('~/.vim/plugged')
Plug 'flazz/vim-colorschemes'
Plug 'jlanzarotta/bufexplorer'
Plug 'xolox/vim-misc'
Plug 'xolox/vim-colorscheme-switcher'
Plug 'ledger/vim-ledger'
Plug 'cespare/vim-toml'
call plug#end()

colo newsprint

source ~/.config/nvim/init/common.vim
source ~/.config/nvim/init/color.vim
source ~/.config/nvim/init/session.vim

"set nocursorline
