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
Plug 'xolox/vim-misc'
Plug 'xolox/vim-colorscheme-switcher'
Plug 'ledger/vim-ledger'
Plug 'fatih/vim-go'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'cespare/vim-toml'

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

"set wildignore+=*/node_modules/*,*/vendor/*,*/npm/*,*/python_automation/*
let g:ctrlp_by_filename = 1
let g:ctrlp_user_command = 'find %s -type f | egrep "\.(go|rs|scala|html|conf|sbt)$" | egrep -v "node_modules|vendor"'

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

"colorscheme deepsea
"colorscheme charged-256
"colorscheme candyman
"colorscheme mushroom
"colorscheme last256

"colorscheme 256_noir
"colo newsprint
colorscheme oxeded

" Custom colors for this particular colorscheme
" https://jonasjacek.github.io/colors/
hi NormalFloat ctermbg=233
hi TabLineFill ctermfg=Gray ctermbg=Black cterm=NONE
hi TabLine ctermfg=Gray ctermbg=Black cterm=NONE
hi TabLineSel ctermfg=Yellow ctermbg=Black cterm=underline,bold
hi CursorLine ctermfg=NONE ctermbg=235 cterm=NONE
hi VertSplit ctermfg=Black ctermbg=DarkGray
hi Visual ctermfg=107 ctermbg=237

if &diff
    colorscheme lettuce
    set nocursorline
endif

set statusline=%f\ %M%R%H%=\ %l,%v\ \:\ %p%%
set laststatus=2    " always display statusline

map to :tabnew<CR>

" Make vim read external changes on focus and buffer change
au FocusGained,BufEnter * :checktime

" Save sessions
fu! SaveSess()
  execute 'mksession! ~/.vim/session.vim'
endfunction

fu! RestoreSess()
  execute 'so ~/.vim/session.vim'
endfunction

autocmd VimLeave * call SaveSess()

nmap <silent> <Leader>vs :call SaveSess()<CR>
nmap <silent> <Leader>vr :call RestoreSess()<CR>

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

set wildignore+=*.xml,*.jar,*.class,*.json,*.properties,*.cache

let g:go_version_warning = 0

"--------------------------------------------------------
" Coc
" -------------------------------------------------------
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor
autocmd CursorHold * silent call CocActionAsync('highlight')
" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

