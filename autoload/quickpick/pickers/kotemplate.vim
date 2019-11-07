function! quickpick#pickers#kotemplate#show(...) abort
  let s:items = kotemplate#complete_load('', '', 0)
  let id = quickpick#create({
        \ 'on_change': function('s:on_change'),
        \ 'on_accept': function('s:on_accept'),
        \ 'items': copy(s:items)
        \})
  call quickpick#show(id)
  return id
endfunction

function! s:on_change(id, action, data) abort " {{{
  let search_text = tolower(a:data)
  call quickpick#set_items(a:id, filter(copy(s:items), 'stridx(tolower(v:val), search_text) >= 0'))
endfunction " }}}

function! s:on_accept(id, action, data) abort " {{{
  call quickpick#close(a:id)
  call kotemplate#load(a:data['items'][0])
  unlet s:items
endfunction " }}}
