"=============================================================================
" FILE: autoload/autoprogramming.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let g:autoprogramming#maxwidth = get(g:, 'autoprogramming#maxwidth', 50)

function! autoprogramming#complete(findstart, base) abort
  if a:findstart
    return autoprogramming#find_start_col()
  endif
  return autoprogramming#completion_items(a:base)
endfunction

function! autoprogramming#find_start_col() abort
  return len(matchstr(getline('.'), '^\s*'))
endfunction

function! autoprogramming#completion_items(base) abort
  let query = s:trim_start(a:base)
  if query ==# ''
    return s:vertical(s:trim_start(getline(line('.')-1)))
  endif
  return s:horizontal(query)
endfunction

function! s:horizontal(query) abort
  let cmd = ['git', 'grep', '--fixed-string', '-h', '-e', a:query]
  let job = autoprogramming#async#new_job(cmd)
  call job.start()
  call job.await({-> complete_check() || getchar(1)})
  let lines = job.stdout
  let re = '^\s*\V' .  escape(a:query, '\')
  let counts = {}
  for line in lines
    if line =~# re
      let l = s:trim_start(line)
      if !has_key(counts, l)
        let counts[l] = 0
      endif
      let counts[l] += 1
    endif
  endfor
  return s:summarize(counts)
endfunction

function! s:vertical(query) abort
  let cmd = ['git', 'grep', '-A1', '--fixed-string', '-h', '-e', a:query]
  let job = autoprogramming#async#new_job(cmd)
  call job.start()
  call job.await({-> complete_check() || getchar(1)})
  let lines = job.stdout
  let counts = {}
  while len(lines) > 1
    if s:trim_start(remove(lines, 0)) ==# a:query
      let l = s:trim_start(remove(lines, 0))
      if !has_key(counts, l)
        let counts[l] = 0
      endif
      let counts[l] += 1
    endif
  endwhile
  return s:summarize(counts)
endfunction

function! s:summarize(counts) abort
  let results = []
  for [line, cnt] in sort(items(a:counts), {a, b -> b[1] - a[1]})
    let results += [{
    \   'word': line,
    \   'abbr': line[:g:autoprogramming#maxwidth],
    \   'menu': printf('(%d)', cnt),
    \ }]
  endfor
  return results
endfunction

function! s:trim_start(str) abort
  return matchstr(a:str,'^\s*\zs.\{-}$')
endfunction

if expand('%:p') ==# expand('<sfile>:p')
  setlocal completefunc=autoprogramming#complete
endif

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
