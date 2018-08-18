if !has('python') && !has('python3')
    echo 'Error: Required vim compiled with +python'
    finish
endif

if !exists('g:ci_show_summary')
    let g:ci_show_summary = 0
endif

if !exists('g:ci_show_explains')
    let g:ci_show_explains = 1
endif

if !exists('g:ci_show_web')
    let g:ci_show_web = 0
endif


let s:param = []
if g:ci_show_summary == 1
    call add(s:param, '-s')
endif

if g:ci_show_explains == 1
    call add(s:param, '-e')
endif

if g:ci_show_web == 1
    call add(s:param, '-w')
endif


function! BackgroundCommandCloseHandler(channel)
  execute 'cfile! ' . s:backgroundCommandOutput
  copen
  unlet s:backgroundCommandOutput
  call win_gotoid(s:win_id)
  call winrestview(s:winview)
endfunction

function! RunBackgroundCommand(command)
  if v:version < 800
    echoerr 'RunBackgroundCommand requires VIM version 8 or higher'
    return
  endif

  let s:win_id = win_getid()
  let s:winview = winsaveview()

  if exists('s:backgroundCommandOutput')
    echo 'Already running task in background'
  else
    echo 'Running task in background'
    let s:backgroundCommandOutput = tempname()
    call job_start(a:command, {'close_cb': 'BackgroundCommandCloseHandler',
                              \'out_io': 'file',
                              \'out_name': s:backgroundCommandOutput})
  endif
endfunction

let s:ci_home = fnamemodify(resolve(expand('<sfile>:p')), ':h')

function! asynci#GetCi()
    let l:word = expand('<cword>')
    call RunBackgroundCommand(['python', s:ci_home . '/../bin/ci.py', join(s:param, ' '), l:word])
endfunction
