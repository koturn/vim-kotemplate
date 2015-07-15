" ============================================================================
" FILE: kotemplate.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" koturn's template loader.
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

command! -bar CtrlPKoTemplate  call s:ctrlp_hook() | delfunction s:crtlp_hook
command! -bar AltiKoTemplate  call s:alti_hook() | delfunction s:alti_hook
command! -bar MilqiKoTemplate  call s:milqi_hook() | delfunction s:milqi_hook

function! s:ctrlp_hook()
  try
    call ctrlp#init(ctrlp#kotemplate#id())
    command! -bar AltiKoTemplate  call ctrlp#init(ctrlp#kotemplate#id())
  catch /^Vim\%((\a\+)\)\=:E\%(117\): .\+: ctrlp#init$/
    delcommand CtrlPKoTemplate
    echoerr 'ctrlpvim/ctrlp.vim is not installed.'
  endtry
endfunction

function! s:alti_hook()
  try
    call alti#init(alti#kotemplate#define())
    command! -bar AltiKoTemplate  call alti#init(alti#kotemplate#define())
  catch /^Vim\%((\a\+)\)\=:E\%(117\): .\+: alti#init$/
    delcommand AltiKoTemplate
    echoerr 'LeafCage/alti.vim is not installed.'
  endtry
endfunction

function! s:milqi_hook()
  try
    call milqi#candidate_first(milqi#kotemplate#define())
    delfunction s:milqi_hook
    command! -bar MilqiKoTemplate  call milqi#candidate_first(milqi#kotemplate#define())
  catch /^Vim\%((\a\+)\)\=:E\%(117\): .\+: milqi#candidate_first$/
    echomsg 'kamichidu/vim-milqi is not installed'
    delcommand MilqiKoTemplate
  endtry
endfunction


augroup KoTemplate
  autocmd!
  autocmd BufNewFile * call kotemplate#auto_action()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
