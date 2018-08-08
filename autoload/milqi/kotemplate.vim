" ============================================================================
" FILE: kotemplate.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" koturn's template loader.
" vim-milqi: https://github.com/kamichidu/vim-milqi
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim

let s:define = {'name': 'kotemplate'}

function! milqi#kotemplate#define() abort " {{{
  return s:define
endfunction " }}}

function! s:define.init(context) abort " {{{
  return kotemplate#complete_load('', '', 0)
endfunction " }}}

function! s:define.accept(context, candidate) abort " {{{
  call milqi#exit()
  call kotemplate#load(a:candidate)
endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo
