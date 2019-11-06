function! s:on_change(id, action, data) abort " {{{
  let search_text = tolower(a:data)
  let items = filter(copy(s:items), {index, item-> stridx(tolower(item), search_text) > -1})
  call quickpick#set_items(a:id, items)
endfunction " }}}

function! s:on_accept(id, action, data) abort " {{{
  call quickpick#close(a:id)
  call kotemplate#load(a:data['items'][0])
  unlet s:items
endfunction " }}}

function! quickpick#kotemplate#id() abort " {{{
  let s:items = kotemplate#complete_load('', '', 0)
  return quickpick#create({
        \ 'on_change': function('s:on_change'),
        \ 'on_accept': function('s:on_accept'),
        \ 'items': copy(s:items)
        \})
endfunction " }}}
