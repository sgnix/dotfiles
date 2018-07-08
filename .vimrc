" Begin of vim-bundle
" -------------------
call plug#begin('~/.vim/plugged')

Plug 'flazz/vim-colorschemes'
Plug 'mileszs/ack.vim'
Plug 'derekwyatt/vim-scala'
Plug 'tpope/vim-fugitive'
Plug 'jlanzarotta/bufexplorer'
Plug 'GEverding/vim-hocon'
Plug 'kien/ctrlp.vim'
"Plug 'vim-airline/vim-airline'
"Plug 'scrooloose/nerdtree'
"Plug 'kien/rainbow_parentheses.vim'
"Plug 'jceb/vim-hier'
Plug 'xolox/vim-misc'
Plug 'xolox/vim-colorscheme-switcher'

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

"set wildignore+=*/node_modules/*,*/vendor/*,*/npm/*,*/python_automation/*
let g:ctrlp_by_filename = 1
let g:ctrlp_user_command = 'find %s -type f | egrep "\.(scala|html|conf|sbt)$" | egrep -v "node_modules|vendor"'

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

"colorscheme desertink
"colorscheme deepsea
"colorscheme darth
"colorscheme colorsbox-faff
"colorscheme charged-256
"colorscheme cobalt2
"colorscheme candyman
"colorscheme calmar256-dark
"colorscheme Benokai
"colorscheme cabin
"colorscheme badwolf
"colorscheme mushroom
"colorscheme jellybeans
colorscheme last256
"colorscheme lettuce
"colorscheme lodestone

if &diff
    colorscheme lettuce
    set nocursorline
endif

set statusline=%f\ %M%R%H%=\ %l,%v\ \:\ %p%%
set laststatus=2    " always display statusline

map to :tabnew<CR>

if has("gui_running")
    set guifont=Menlo\ Regular:h16
endif

" Make vim read external changes on focus and buffer change
if !has("gui_running")
    au FocusGained,BufEnter * :checktime
endif

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

noremap <silent> <Leader>lf :call ScalaFollowTrait()<CR>
nmap <silent> <Leader>vs :call SaveSess()<CR>
nmap <silent> <Leader>vr :call RestoreSess()<CR>

let g:ack_default_options = " -s -H --nocolor --nogroup --column"

" Auto-highlight the current word
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

" -------------------------------------------------
" Scala stuff
" -------------------------------------------------

set wildignore+=*.xml,*.jar,*.class,*.json,*.properties,*.cache

" sbt quickfix stuff
set errorformat=%E\ %#[error]\ %#%f:%l:\ %m,%-Z\ %#[error]\ %p^,%-C\ %#[error]\ %m
set errorformat+=,%W\ %#[warn]\ %#%f:%l:\ %m,%-Z\ %#[warn]\ %p^,%-C\ %#[warn]\ %m
set errorformat+=,%-G%.%#
noremap <silent> <Leader>ff :cf target/sbt.quickfix<CR>
noremap <silent> <Leader>fn :cn<CR>

" Find who uses the trait or class under the cursor
function! ScalaFollowTrait()
    let wordUnderCursor = expand("<cword>")
    execute 'Ack --type=scala "(with|extends)\s+"'.wordUnderCursor
endfunction

" Ack for the word under cursor
function! ScalaSearchWord()
    let wordUnderCursor = expand("<cword>")
    execute 'Ack --type=scala '.wordUnderCursor
endfunction

function! ScalaDeclaration()
    let wordUnderCursor = expand("<cword>")
    execute 'Ack --type=scala "(trait|class)\s+"'.wordUnderCursor
endfunction


noremap <silent> <Leader>sf :call ScalaFollowTrait()<CR>
noremap <silent> <Leader>ss :call ScalaSearchWord()<CR>
noremap <silent> <Leader>sd :call ScalaDeclaration()<CR>
noremap <silent> <Leader>gs :Gstatus<CR>
noremap <silent> <Leader>gd :Gdiff<CR>
noremap <silent> <Leader>gb :Gblame<CR>
