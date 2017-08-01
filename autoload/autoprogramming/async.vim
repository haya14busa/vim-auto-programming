"=============================================================================
" FILE: autoload/autoprogramming/async.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:job = {
\   'cmd': [],
\   'stdout': [],
\   'exited': 0,
\ }

function! autoprogramming#async#new_job(cmd) abort
  let job = deepcopy(s:job)
  let job.cmd = a:cmd
  return job
endfunction

if has('nvim')
  function! s:job.start() abort
    let self.job = jobstart(self.cmd, extend(self, {
    \   'on_stdout': self._out_cb,
    \   'on_exit': self._exit_cb,
    \ }))
  endfunction
else
  function! s:job.start() abort
    let self.job = job_start(self.cmd, {
    \   'out_cb': self._out_cb,
    \   'exit_cb': self._exit_cb,
    \ })
  endfunction
endif

function! s:job._exit_cb(...) abort
  let self.exited = 1
endfunction

function! s:job.await(...) abort
  let l:DoneF = get(a:, 1, {->0})
  while !l:DoneF() && !self.exited
    sleep 5ms
  endwhile
endfunction

if has('nvim')
  function! s:job._out_cb(_job_id, data, event) abort
    let self.stdout += a:data[:-2]
  endfunction
else
  function! s:job._out_cb(ch, msg) abort
    let self.stdout += split(a:msg, "\n")
  endfunction
endif

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
