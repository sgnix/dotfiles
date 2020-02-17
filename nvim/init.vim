"set runtimepath^=~/.vim runtimepath+=~/.vim/after
"let &packpath = &runtimepath
"source ~/.vimrc

call plug#begin('~/.vim/plugged')
Plug 'flazz/vim-colorschemes'
Plug 'mileszs/ack.vim'
Plug 'tpope/vim-fugitive'
Plug 'jlanzarotta/bufexplorer'
Plug 'kien/ctrlp.vim'
Plug 'xolox/vim-misc'
Plug 'xolox/vim-colorscheme-switcher'
Plug 'ledger/vim-ledger'
Plug 'cespare/vim-toml'
call plug#end()

source ~/.config/nvim/init/common.vim
source ~/.config/nvim/init/color.vim
source ~/.config/nvim/init/session.vim
