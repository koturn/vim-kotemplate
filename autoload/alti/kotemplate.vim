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


" {{{ Get SID
function! s:get_sid_prefix() abort " {{{
  return matchstr(expand('<sfile>'), 'function \zs<SNR>\d\+_\zeget_sid_prefix$')
endfunction " }}}
let s:sid_prefix = s:get_sid_prefix()
delfunction s:get_sid_prefix
" }}}

let s:define = {
      \ 'name': 'kotemplate',
      \ 'enter': s:sid_prefix . 'enter',
      \ 'cmpl': s:sid_prefix . 'cmpl',
      \ 'prompt': s:sid_prefix . 'prompt',
      \ 'submitted': s:sid_prefix . 'submitted'
      \}
unlet s:sid_prefix

function! alti#kotemplate#define() abort " {{{
  return s:define
endfunction " }}}


function! s:enter() abort dict " {{{
  let self.candidates = kotemplate#complete_load('', '', 0)
endfunction " }}}

function! s:cmpl(context) abort dict " {{{
  return a:context.fuzzy_filtered(self.candidates)
endfunction " }}}

function! s:prompt(context) abort " {{{
  return 'KoTemplate> '
endfunction " }}}

function! s:submitted(context, line) abort " {{{
  call kotemplate#load(len(a:context.inputs) == 0 ? a:context.selection : a:context.inputs[0])
endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo
