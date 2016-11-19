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
\ }

function! autoprogramming#async#new_job(cmd) abort
  let job = deepcopy(s:job)
  let job.cmd = a:cmd
  return job
endfunction

function! s:job.start() abort
  let self.job = job_start(self.cmd, {
  \   'out_cb': self._out_cb,
  \ })
endfunction

function! s:job.await(...) abort
  let l:DoneF = get(a:, 1, {->0})
  while !l:DoneF() && job_status(self.job) ==# "run"
    sleep 5ms
  endwhile
endfunction

function! s:job._out_cb(ch, msg) abort
  let self.stdout += split(a:msg, "\n")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
