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
  return s:horizontal(query, 0)
endfunction

function! s:horizontal(query, skip) abort
  let shortq = s:shorten(a:query, a:skip)
  if shortq ==# ''
    return []
  endif
  let cmd = ['git', 'grep', '--fixed-string', '-h', '-e', shortq]
  let job = autoprogramming#async#new_job(cmd)
  call job.start()
  call job.await({-> complete_check() || getchar(1)})
  let lines = job.stdout
  if empty(lines)
    return s:horizontal(a:query, a:skip+1)
  endif
  let counts = {}
  for line in lines
    let compl = s:compl(line, shortq, a:skip ==# 0)
    if compl !=# ""
      let l = s:base(a:query, shortq) . compl
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

function! s:shorten(str, i) abort
  let p = printf('^\%%(\s*\S\+\s*\)\{,%d}', a:i)
  return substitute(a:str, p, '', '')
endfunction

function! s:base(original_query, short_query) abort
  let r = ''
  let i = stridx(a:original_query, a:short_query)
  if i > 0
    let r = a:original_query[:i-1]
  endif
  return s:trim_start(r . a:short_query)
endfunction

function! s:compl(found, short_query, whole_line) abort
  let i = stridx(a:found, a:short_query)
  if i > 0 && a:found[i-1] =~# '\k'
    return ''
  endif
  let rest = a:found[i + len(a:short_query):]
  if a:whole_line
    return rest
  endif
  return matchstr(rest, '^\s*\(\k\+\|\S\+\)')
endfunction

if expand('%:p') ==# expand('<sfile>:p')
  setlocal completefunc=autoprogramming#complete
endif

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
