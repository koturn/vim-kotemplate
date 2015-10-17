" ============================================================================
" FILE: kotemplate.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" koturn's template loader.
" ctrlp.vim: https://github.com/ctrlpvim/ctrlp.vim
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim
if exists('g:loaded_ctrlp_kotemplate') && g:loaded_ctrlp_kotemplate
  finish
endif
let g:loaded_ctrlp_kotemplate = 1
let s:ctrlp_builtins = ctrlp#getvar('g:ctrlp_builtins')

let s:kotemplate_var = {
      \ 'init': 'ctrlp#kotemplate#init()',
      \ 'accept': 'ctrlp#kotemplate#accept',
      \ 'enter': 'ctrlp#kotemplate#enter()',
      \ 'lname': 'kotemplate',
      \ 'sname': 'kotemplate',
      \ 'type': 'line',
      \ 'sort': 0
      \}
if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
  let g:ctrlp_ext_vars = add(g:ctrlp_ext_vars, s:kotemplate_var)
else
  let g:ctrlp_ext_vars = [s:kotemplate_var]
endif
let s:id = s:ctrlp_builtins + len(g:ctrlp_ext_vars)
unlet s:ctrlp_builtins

function! ctrlp#kotemplate#id() abort
  return s:id
endfunction

function! ctrlp#kotemplate#init() abort
  return s:candidates
endfunction

function! ctrlp#kotemplate#accept(mode, str) abort
  call ctrlp#exit()
  call kotemplate#load(a:str)
endfunction

function! ctrlp#kotemplate#enter() abort
  let s:candidates = kotemplate#complete_load('', '', 0)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
