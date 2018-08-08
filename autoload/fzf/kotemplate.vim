" ============================================================================
" FILE: kotemplate.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" koturn's template loader.
" fzf: https://github.com/junegunn/fzf
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


let s:option = {
      \ 'down': '25%'
      \}
function! s:option.sink(candidate) abort " {{{
  call kotemplate#load(a:candidate)
endfunction " }}}


function! fzf#kotemplate#option() abort " {{{
  let s:option.source = kotemplate#complete_load('', '', 0)
  return s:option
endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo
