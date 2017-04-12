if has('channel') && has('job')
    nnoremap <F2> :call asynci#GetCi()<cr>
    vnoremap <F2> :call asynci#GetCi()<cr>
    inoremap <F2> :call asynci#GetCi()<cr>
else
  nnoremap <F2> :call ci#GetCi()<cr>
  vnoremap <F2> :call ci#GetCi()<cr>
  inoremap <F2> :call ci#GetCi()<cr>
endif
