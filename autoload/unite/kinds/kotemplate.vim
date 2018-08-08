" ============================================================================
" FILE: kotemplate.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" koturn's template loader.
" unite.vim: https://github.com/Shougo/unite.vim
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


let s:kind = {
      \ 'name': 'kotemplate',
      \ 'action_table': {},
      \ 'default_action': 'load_template'
      \}

let s:kind.action_table.load_template = {
      \ 'description': 'Load template file'
      \}
function! s:kind.action_table.load_template.func(candidate) abort " {{{
  call kotemplate#load(a:candidate.word)
endfunction " }}}


function! unite#kinds#kotemplate#define() abort " {{{
  return s:kind
endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo
