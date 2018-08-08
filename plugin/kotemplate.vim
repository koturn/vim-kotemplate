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


" {{{ Commands
command! -bar -nargs=+ -complete=customlist,kotemplate#complete_load KoTemplateLoad  call kotemplate#load(<f-args>)
command! -bar -bang -nargs=+ -complete=customlist,kotemplate#complete_project KoTemplateMakeProject  call kotemplate#make_project(<bang>0, <f-args>)

command! -bar CtrlPKoTemplate  call s:ctrlp_hook() | delfunction s:ctrlp_hook
command! -bar AltiKoTemplate  call s:alti_hook() | delfunction s:alti_hook
command! -bar MilqiKoTemplate  call s:milqi_hook() | delfunction s:milqi_hook
command! -bar FZFKotemplate  call s:fzf_hook() | delfunction s:fzf_hook
" }}}

function! s:ctrlp_hook() abort " {{{
  try
    call ctrlp#init(ctrlp#kotemplate#id())
    command! -bar CtrlPKoTemplate  call ctrlp#init(ctrlp#kotemplate#id())
  catch /^Vim(call)\=:E117: .\+: ctrlp#getvar$/
    delcommand CtrlPKoTemplate
    echoerr 'ctrlpvim/ctrlp.vim is not installed.'
  endtry
endfunction " }}}

function! s:alti_hook() abort " {{{
  try
    call alti#init(alti#kotemplate#define())
    command! -bar AltiKoTemplate  call alti#init(alti#kotemplate#define())
  catch /^Vim(call)\=:E117: .\+: alti#init$/
    delcommand AltiKoTemplate
    echoerr 'LeafCage/alti.vim is not installed.'
  endtry
endfunction " }}}

function! s:milqi_hook() abort " {{{
  try
    call milqi#candidate_first(milqi#kotemplate#define())
    command! -bar MilqiKoTemplate  call milqi#candidate_first(milqi#kotemplate#define())
  catch /^Vim(call)\=:E117: .\+: milqi#candidate_first$/
    delcommand MilqiKoTemplate
    echomsg 'kamichidu/vim-milqi is not installed'
  endtry
endfunction " }}}

function! s:fzf_hook() abort " {{{
  try
    call fzf#run(fzf#kotemplate#option())
    command! -bar FZFKotemplate  call fzf#run(fzf#kotemplate#option())
  catch /^Vim(call)\=:E117: .\+: fzf#run$/
    delcommand FZFKoTemplate
    echomsg 'plugin/fzf.vim (in junegunn/fzf) is not found. Please check your runtimepath'
  endtry
endfunction " }}}


augroup KoTemplate " {{{
  autocmd!
  autocmd BufNewFile * call kotemplate#auto_action()
augroup END " }}}


let &cpo = s:save_cpo
unlet s:save_cpo
