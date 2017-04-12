if !has('python')
    echo "Error: Required vim compiled with +python"
    finish
endif

if !exists('g:ci_show_generalization')
    let g:ci_show_generalization = 0
endif

if !exists('g:ci_show_explains')
    let g:ci_show_explains = 1
endif

if !exists('g:ci_show_web')
    let g:ci_show_web = 0
endif

function! BackgroundCommandCloseHandler(channel)
  execute "cfile! " . g:backgroundCommandOutput
  copen
  unlet g:backgroundCommandOutput
  call win_gotoid(g:win_id)
  call winrestview(g:winview)
endfunction

function! RunBackgroundCommand(command)
  if v:version < 800
    echoerr 'RunBackgroundCommand requires VIM version 8 or higher'
    return
  endif

  let g:win_id = win_getid()
  let g:winview = winsaveview()

  if exists('g:backgroundCommandOutput')
    echo 'Already running task in background'
  else
    echo 'Running task in background'
    let g:backgroundCommandOutput = tempname()
    call job_start(a:command, {'close_cb': 'BackgroundCommandCloseHandler',
                              \'out_io': 'file',
                              \'out_name': g:backgroundCommandOutput})
  endif
endfunction

function! asynci#GetCi()
    let s:word = expand('<cword>')
    call RunBackgroundCommand(['python', '/home/eagle/.vim/bundle/Ci/bin/ci.py', '-b', s:word])
endfunction
