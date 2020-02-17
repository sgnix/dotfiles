fu! SaveSess()
  execute 'mksession! ~/.vim/session.vim'
endfunction

fu! RestoreSess()
  execute 'so ~/.vim/session.vim'
endfunction

autocmd VimLeave * call SaveSess()

nmap <silent> <Leader>vs :call SaveSess()<CR>
nmap <silent> <Leader>vr :call RestoreSess()<CR>
