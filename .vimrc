" Begin of vim-bundle
" -------------------
call plug#begin('~/.vim/plugged')

Plug 'flazz/vim-colorschemes'
Plug 'mileszs/ack.vim'
Plug 'derekwyatt/vim-scala'
Plug 'tpope/vim-fugitive'
Plug 'jlanzarotta/bufexplorer'
Plug 'scrooloose/nerdtree'

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

set ruler
set backupdir=./.backup,/tmp
set directory=./.backup,/tmp

" no bell of any kind
set vb t_vb=

" incremental search
set incsearch
set nohlsearch

" look for tags up the dir hierarchy
set tags=tags;/

" Remap jj to Escape
inoremap jj <Esc>
inoremap ,, =>
nmap g/ :Ex<CR>
nmap g' :ToggleBufExplorer<CR>
nmap <C-N> :NERDTree<CR>

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

"colorscheme cobalt2
"colorscheme candyman
"colorscheme calmar256-dark
"colorscheme Benokai
"colorscheme cabin
"colorscheme badwolf
colorscheme mushroom
"colorscheme jellybeans
"colorscheme last256
"colorscheme lettuce
"colorscheme lodestone

set statusline=%f\ %M%R%H%=\ %l,%v\ \:\ %p%%
set laststatus=2    " always display statusline

map to :tabnew<CR>

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

let g:ack_default_options = " -s -H --nocolor --nogroup --column"

nnoremap z/ :if AutoHighlightToggle()<Bar>set hls<Bar>endif<CR>
function! AutoHighlightToggle()
    let @/ = ''
    if exists('#auto_highlight')
        au! auto_highlight
        augroup! auto_highlight
        setl updatetime=4000
        echo 'Highlight current word: off'
        return 0
    else
        augroup auto_highlight
            au!
            au CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
        augroup end
        setl updatetime=500
        echo 'Highlight current word: ON'
        return 1
    endif
endfunction


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

set tabline=%!MyTabLine()
