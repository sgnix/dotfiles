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
Plug 'posva/vim-vue'

call plug#end()
"------------------------

colo basic-dark

source ~/.config/nvim/init/common.vim
source ~/.config/nvim/init/color.vim
source ~/.config/nvim/init/session.vim

let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files']
set wildignore+=node_modules/**

let g:vue_pre_processors = 'detect_on_enter'

ab _div <div><Enter></div><Up>
ab _tml <template><Enter></template><Up>
ab edc export default class
ab ede export default
ab itt it("", () => {<Enter>})
