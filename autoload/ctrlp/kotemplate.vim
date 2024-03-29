" ============================================================================
" FILE: kotemplate.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" koturn's template loader.
" ctrlp.vim: https://github.com/ctrlpvim/ctrlp.vim
" }}}
" ============================================================================
if exists('g:loaded_ctrlp_kotemplate') && g:loaded_ctrlp_kotemplate
  finish
endif
let g:loaded_ctrlp_kotemplate = 1
let s:save_cpo = &cpo
set cpo&vim

let s:ctrlp_builtins = ctrlp#getvar('g:ctrlp_builtins')

" {{{ Get SID
function! s:get_sid_prefix() abort " {{{
  return matchstr(expand('<sfile>'), '\zs<SNR>\d\+_\zeget_sid_prefix$')
endfunction " }}}
let s:sid_prefix = s:get_sid_prefix()
delfunction s:get_sid_prefix
" }}}

let g:ctrlp_ext_vars = add(get(g:, 'ctrlp_ext_vars', []), {
      \ 'init': s:sid_prefix . 'init()',
      \ 'accept': s:sid_prefix . 'accept',
      \ 'enter': s:sid_prefix . 'enter()',
      \ 'exit': s:sid_prefix . 'exit()',
      \ 'lname': 'kotemplate',
      \ 'sname': 'kotemplate',
      \ 'type': 'path',
      \ 'sort': 0,
      \ 'nolim': 1
      \})
let s:id = s:ctrlp_builtins + len(g:ctrlp_ext_vars)
unlet s:ctrlp_builtins s:sid_prefix


function! ctrlp#kotemplate#id() abort " {{{
  return s:id
endfunction " }}}


function! s:init() abort " {{{
  return s:candidates
endfunction " }}}

function! s:accept(mode, str) abort " {{{
  call ctrlp#exit()
  call kotemplate#load(a:str)
  silent doautocmd KoTemplate User TemplateLoaded
endfunction " }}}

function! s:enter() abort " {{{
  let s:candidates = kotemplate#complete_load('', '', 0)
endfunction " }}}

function! s:exit() abort " {{{
  unlet! s:candidates
endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo
