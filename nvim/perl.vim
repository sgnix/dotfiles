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
Plug 'vim-perl/vim-perl'
Plug 'cespare/vim-toml'
Plug 'preservim/nerdcommenter'

call plug#end()
"------------------------

colo jellybeans

source ~/.config/nvim/init/common.vim
source ~/.config/nvim/init/color.vim
source ~/.config/nvim/init/session.vim

let g:go_version_warning = 0

let g:ctrlp_by_filename = 1
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files']

let perl_sub_signatures = 1    
let perl_include_pod = 0    

iabbrev survery survey    
iabbrev survery_id survey_id    
iabbrev teh the
iabbrev mss my $self = shift;
iabbrev iff if ( ) {<Enter>}<Up><Right><Right><Right>                                          
iabbrev subb sub {<Enter>}<Up><Right><Right>
iabbrev forr for ( ) {<Enter>}<Up><Right><Right><Right><Right>
