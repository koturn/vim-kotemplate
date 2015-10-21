" ============================================================================
" FILE: kotemplate.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" koturn's template loader.
" alti.vim: https://github.com/LeafCage/alti.vim
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


let s:define = {
      \ 'name': 'kotemplate'
      \ 'enter': 'alti#kotemplate#enter',
      \ 'cmpl': 'alti#kotemplate#cmpl',
      \ 'prompt': 'alti#kotemplate#prompt',
      \ 'submitted': 'alti#kotemplate#submitted'
      \}

function! alti#kotemplate#define() abort
  return s:define
endfunction

function! alti#kotemplate#enter() abort dict
  let self.candidates = kotemplate#complete_load('', '', 0)
endfunction

function! alti#kotemplate#cmpl(context) abort dict
  return a:context.fuzzy_filtered(self.candidates)
endfunction

function! alti#kotemplate#prompt(context) abort
  return 'KoTemplate> '
endfunction

function! alti#kotemplate#submitted(context, line) abort
  call kotemplate#load(a:context.selection)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
