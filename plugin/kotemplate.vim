" ============================================================================
" FILE: kotemplate.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" Last Modified: 2015 07/07
" DESCRIPTION: {{{
" descriptions.
" }}}
" ============================================================================
if exists('g:loaded_kotemplate')
  finish
endif
let g:loaded_kotemplate = 1
let s:save_cpo = &cpo
set cpo&vim


command! -bar -nargs=+ -complete=customlist,kotemplate#complete_load KoTemplateLoad  call kotemplate#load(<f-args>)
command! -bar -nargs=+ -complete=customlist,kotemplate#complete_project KoTemplateMakeProject  call kotemplate#make_project(<f-args>)

augroup KoTemplate
  autocmd!
  autocmd BufNewFile * call kotemplate#auto_action()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
