"colorscheme deepsea
"colorscheme charged-256
"colorscheme candyman
"colorscheme mushroom
"colorscheme last256

"colorscheme 256_noir
"colo newsprint
"colorscheme oxeded

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

