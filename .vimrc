" Begin of vim-bundle
" -------------------
call plug#begin('~/.vim/plugged')

Plug 'flazz/vim-colorschemes'
Plug 'Raimondi/delimitMate'
Plug 'mileszs/ack.vim'
Plug 'troydm/easybuffer.vim'
Plug 'xolox/vim-misc'
Plug 'xolox/vim-colorscheme-switcher'
Plug 'kchmck/vim-coffee-script'
Plug 'https://github.com/genoma/vim-less.git'
Plug 'https://github.com/leafgarland/typescript-vim.git'
"Plug 'hallison/vim-markdown'
"Plug 'AutoComplPop'
"Plug 'fatih/vim-go'
"Plug 'zah/nimrod.vim'
"Plug 'https://github.com/lambdatoast/elm.vim.git'

call plug#end()
"------------------------
" End of vim-bundle

set nocp
set ai
set nu
set autoread

" Use spaces no tabs
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set hidden
set nowrap
set cursorline

" Show the command you're typing
set showcmd

" Open new split panes to right and bottom, which feels more natural than
" Vim's default:
set splitbelow
set splitright

" Move cursor through whitespace
"set ve=all

set ruler
set backupdir=./.backup,/tmp
set directory=./.backup,/tmp

" no bell of any kind
set vb t_vb=

" incremental search
set incsearch
set nohlsearch

" Remap jj to Escape
inoremap jj <Esc>
inoremap ,, =>
inoremap ,. ->
nmap <C-e> :e#<CR>
nmap g/ :Ex<CR>
nmap g' :EasyBuffer<CR>

" PageUp and PageDown
" Shift-Space and Space
map _ <PageUp>
map <Space> <PageDown>

" comment/uncomment blocks of code
nmap \c V%:s/^/#/gi<Enter>
nmap \C V%:s/^#//gi<Enter>
vmap \c :s/^/#/gi<Enter>
vmap \C :s/^#//gi<Enter>

" perl
vmap \pt :!perltidy<Enter>
nmap \pt V%:!perltidy<Enter>
imap \ps my $self = shift;<Enter>
inoremap \sub => sub {<Return>};<UP><Esc>o<TAB>
nmap \pf :Ack "^\s*sub\s+\w+" %<Enter>

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" paste
nmap \po :set paste<Enter>o
nmap \pp :set nopaste<Enter>

" Set English spelling but don't autospell
setlocal spell spelllang=en_us
set nospell

" Syntax highlight
filetype plugin on
syntax on
" let g:loaded_matchparen=1

" Status line
set laststatus=2
" set statusline=%{hostname()}%{fugitive#statusline()}\:%f[%M%R%H]%=\ %l,%v\ \:\ %p%%
set statusline=%f\ %M%R%H%=\ %l,%v\ \:\ %p%%

" Set terminal title
autocmd BufEnter * let &titlestring = hostname() . ": vim(" . expand("%:t") . ")"

" Syntax
au BufNewFile,BufRead *.psgi  set filetype=perl
au BufNewFile,BufRead *.tx    set filetype=tx
au BufNewFile,BufRead *.less  set filetype=less
au BufNewFile,BufRead *.tt    set filetype=tt2html
au BufNewFile,BufRead *.moon  set filetype=moon
au BufNewFile,BufRead *.dart  set filetype=dart
au BufNewFile,BufRead *.nim   set filetype=nimrod

autocmd Filetype html       setlocal ts=2 sts=2 sw=2
autocmd Filetype tt2html    setlocal ts=2 sts=2 sw=2
autocmd Filetype javascript setlocal ts=2 sts=2 sw=2
autocmd Filetype less       setlocal ts=2 sts=2 sw=2
autocmd Filetype go         setlocal ts=3 noexpandtab nosmarttab

" CoffeeScript
autocmd BufWritePost *.coffee silent make!
autocmd QuickFixCmdPost * nested cwindow | redraw!

if has("gui_running")
  if has("gui_gtk2")
    set guifont=Consolas\ 10
  elseif has("gui_macvim")
    set guifont=Menlo\ Regular:h14
  endif
  colo jellybeans
else
  colorscheme jellybeans
endif

map to :tabnew<CR>

" Remove any trailing whitespace that is in the file
"autocmd BufRead,BufWrite * if ! &bin | silent! %s/\s\+$//ge | endif

let perl_include_pod = 1
let delimitMate_expand_space = 1
let delimitMate_expand_cr = 1

" Turn off AutoComplPop for HTML (annoying)
let acp_behaviorHtmlOmniLength = -1

" Save sessions
fu! SaveSess()
    if has("gui_running")
        execute 'mksession! ~/.vim/gsession.vim'
    else
        execute 'mksession! ~/.vim/session.vim'
    endif
endfunction

fu! RestoreSess()
    if has("gui_running")
        execute 'so ~/.vim/gsession.vim'
    else
        execute 'so ~/.vim/session.vim'
    endif
endfunction

autocmd VimLeave * call SaveSess()

nmap \S :call SaveSess()<CR>
nmap \s :call RestoreSess()<CR>
