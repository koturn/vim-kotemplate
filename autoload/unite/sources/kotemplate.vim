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


let s:source = {
      \ 'name': 'kotemplate',
      \ 'description': 'Template loader',
      \ 'default_kind': 'kotemplate'
      \}

function! s:source.gather_candidates(args, context) abort " {{{
  return map(kotemplate#complete_load('', '', 0), '{"word": v:val}')
endfunction " }}}

function! unite#sources#kotemplate#define() abort " {{{
  return s:source
endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo
