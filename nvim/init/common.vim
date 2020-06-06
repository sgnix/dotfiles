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
ab ,, =>
ab ,. ->
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

let g:ack_default_options = " -s -H --nocolor --nogroup --column"

" Custom tabs
if !has("gui_running")
    if exists("+showtabline")
         function MyTabLine()
             let s = ''
             let t = tabpagenr()
             let i = 1
             while i <= tabpagenr('$')
                 let buflist = tabpagebuflist(i)
                 let winnr = tabpagewinnr(i)
                 let s .= '%' . i . 'T'
                 let s .= (i == t ? '%1*' : '%2*')
                 let s .= ' '
                 let s .= i . ' '
                 let s .= '%*'
                 let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
                 let file = bufname(buflist[winnr - 1])
                 let file = fnamemodify(file, ':p:t')
                 if file == ''
                     let file = '[No Name]'
                 endif
                 let s .= file
                 let i = i + 1
             endwhile
             let s .= '%T%#TabLineFill#%='
             let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
             return s
         endfunction
         set stal=2
         set tabline=%!MyTabLine()
    endif
endif

set tabline=%!MyTabLine()
set statusline=%f\ %M%R%H%=\ %l,%v\ \:\ %p%%
set laststatus=2    " always display statusline

