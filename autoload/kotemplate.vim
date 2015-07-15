" ============================================================================
" FILE: kotemplate.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" koturn's template loader.
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim

let g:kotemplate#dir = get(g:, 'kotemplate#dir', '~/.vim/template/')
let g:kotemplate#tag_actions = get(g:, 'kotemplate#tag_actions', [])
let g:kotemplate#filter = get(g:, 'kotemplate#filter', {})
let g:kotemplate#n_choises = get(g:, 'kotemplate#n_choises', 5)
let g:kotemplate#autocmd_function = get(g:, 'kotemplate#autocmd_function', 'inputlist')
let g:kotemplate#enable_template_cache = get(g:, 'kotemplate#enable_template_cache', 1)
let g:kotemplate#enable_autocmd = get(g:, 'kotemplate#enable_autocmd', 0)
let g:kotemplate#auto_filetypes = get(g:, 'kotemplate#auto_filetypes', [])
let g:kotemplate#projects = get(g:, 'kotemplate#projects', {})
let g:kotemplate#fileencoding = get(g:, 'kotemplate#fileencoding', 'utf-8')
let g:kotemplate#fileformat = get(g:, 'kotemplate#fileformat', 'unix')


function! kotemplate#load(template_path, ...) abort
  let template_file = expand(s:add_path_separator(g:kotemplate#dir) . a:template_path)
  if !filereadable(template_file)
    echoerr 'File not found:' template_file
    return
  endif
  execute 'silent ' . (line('.') - 1) . 'read ' . template_file
  let tag_actions = type(g:kotemplate#tag_actions) == type({}) ?
        \ [g:kotemplate#tag_actions] : g:kotemplate#tag_actions
  for tag_action in tag_actions
    for [tag, Action] in items(tag_action)
      if type(Action) == type(function('function'))
        execute 'silent %s/' . tag . '/\=Action(tag)/ge'
      else
        execute 'silent %s/' . tag . '/\=s:eval(Action)/ge'
      endif
      unlet Action
    endfor
  endfor
  let i = 1
  for va_arg_action in a:000
    let tag = printf('<-ARG%d->', i)
    execute 'silent %s/' . tag . '/\=s:eval(va_arg_action)/ge'
    let i += 1
  endfor
endfunction

function! kotemplate#auto_action() abort
  if g:kotemplate#enable_autocmd
    autocmd! KoTemplate FileType *
    autocmd KoTemplate FileType * call s:auto_action()
  endif
endfunction

function! kotemplate#make_project(project_name, template_project_name) abort
  let project = has_key(g:kotemplate#projects, a:template_project_name) ?
        \ g:kotemplate#projects[a:template_project_name] : {}
  if !isdirectory(a:project_name)
    call mkdir(a:project_name)
  endif
  let s:project_name = string(a:project_name)
  call s:make_project(project, s:add_path_separator(a:project_name))
endfunction

function! kotemplate#complete_load(arglead, cmdline, cursorpos) abort
  let shellslash = &shellslash
  set shellslash
  let nargs = a:cmdline ==# '' ? 1 : len(split(split(a:cmdline, '\s*\\\@<!|\s*')[-1], '\s\+'))
  if nargs == 1 || (nargs == 2 && a:arglead !=# '')
    let candidates = s:get_filter_function()(map(s:gather_template_files(),
          \ printf('substitute(v:val, "^%s", "", "g")',
          \ expand(s:add_path_separator(g:kotemplate#dir)))))
    let &shellslash = shellslash
    return filter(candidates, 'stridx(tolower(v:val), tolower(a:arglead)) == 0')
  endif
  let &shellslash = shellslash
endfunction

function! kotemplate#complete_project(arglead, cmdline, cursorpos) abort
  let nargs = len(split(split(a:cmdline, '\s*\\\@<!|\s*')[-1], '\s\+'))
  if nargs == 2 || (nargs == 3 && a:arglead !=# '')
    return filter(keys(g:kotemplate#projects), 'stridx(tolower(v:val), tolower(a:arglead)) == 0')
  endif
endfunction


function! s:auto_action() abort
  autocmd! KoTemplate FileType *
  if !count(g:kotemplate#auto_filetypes, &filetype) || filereadable(expand('%:p'))
    return
  endif
  call s:get_autocmd_function()()
endfunction

function! s:auto_action_excommand() abort
  call feedkeys(":\<C-u>KoTemplateLoad ")
endfunction

function! s:auto_action_rawinput() abort
  let input = s:input('Input template file name> ', '', 'customlist,kotemplate#complete_load')
  redraw!
  if type(input) != type(0)
    call kotemplate#load(file)
  endif
endfunction

function! s:auto_action_getchar() abort
  let template_files = kotemplate#complete_load('', '', 0)
  let from = 0
  let to = g:kotemplate#n_choises - 1
  let fileidx = 1
  let n_choises = g:kotemplate#n_choises > 9 ? 9 : g:kotemplate#n_choises
  echo "Select template file to load. (Input nothing if you don't want to load template file)"
  while from < len(template_files)
    let i = 1
    let msg = ''
    while i <= n_choises && fileidx - 1 < len(template_files)
      let msg .= printf("  %d. %s\n", i, template_files[from + i - 1])
      let fileidx += 1
      let i += 1
    endwhile
    echo msg . '> '
    let ch = getchar()
    if ch ==# char2nr("\<Esc>")
      return
    endif
    let nr = ch + from - char2nr('0') - 1
    if from <= nr && nr <= to && nr < len(template_files)
      call kotemplate#load(template_files[nr])
      return
    endif
    let from += n_choises
    let to += n_choises
  endwhile
endfunction

function! s:auto_action_input() abort
  let template_files = kotemplate#complete_load('', '', 0)
  let from = 0
  let to = g:kotemplate#n_choises - 1
  let fileidx = 1
  echo "Select template file to load. (Input nothing if you don't want to load template file)"
  while from < len(template_files)
    let i = 1
    let msg = ''
    while i <= g:kotemplate#n_choises && fileidx - 1 < len(template_files)
      let msg .= printf("  %d. %s\n", fileidx, template_files[from + i - 1])
      let fileidx += 1
      let i += 1
    endwhile
    let input = s:input(msg . '> ')
    if input !=# ''
      let nr = str2nr(input) - 1
      if 0 <= nr && nr <= to && nr < len(template_files)
        call kotemplate#load(template_files[nr])
        return
      endif
    elseif type(input) == type(0)
      return
    else
      echo "\n"
    endif
    let from += g:kotemplate#n_choises
    let to += g:kotemplate#n_choises
  endwhile
endfunction

function! s:auto_action_inputlist() abort
  let template_files = kotemplate#complete_load('', '', 0)
  let msg = "Select template file to load. (Input nothing if you don't want to load template file)"
  let from = 0
  let to = g:kotemplate#n_choises - 1
  let choises = insert(template_files[from : to], msg)
  let fileidx = 1
  while from < len(template_files)
    let i = 1
    while i < len(choises) && fileidx - 1 < len(template_files)
      let choises[i] = printf('  %d. %s', fileidx, template_files[from + i - 1])
      let fileidx += 1
      let i += 1
    endwhile
    if i - 1 < g:kotemplate#n_choises
      let choises = choises[0 : i - 1]
    endif
    let nr = inputlist(choises) - 1
    if 0 <= nr && nr <= to && nr < len(template_files)
      call kotemplate#load(template_files[nr])
      return
    endif
    let from += g:kotemplate#n_choises
    let to += g:kotemplate#n_choises
    let choises[0] = ''
  endwhile
endfunction

function! s:auto_action_unite() abort
  Unite kotemplate
endfunction

function! s:auto_action_ctrlp() abort
  call ctrlp#init(ctrlp#kotemplate#id())
endfunction

function! s:auto_action_alti() abort
  call alti#init(alti#kotemplate#define())
endfunction

let s:autocmd_functions = {
      \ 'excommand': function('s:auto_action_excommand'),
      \ 'getchar': function('s:auto_action_getchar'),
      \ 'rawinput': function('s:auto_action_rawinput'),
      \ 'input': function('s:auto_action_input'),
      \ 'inputlist': function('s:auto_action_inputlist'),
      \ 'unite': function('s:auto_action_unite'),
      \ 'ctrlp': function('s:auto_action_ctrlp'),
      \ 'alti': function('s:auto_action_alti')
      \}

function! s:get_autocmd_function() abort
  if has_key(s:autocmd_functions, g:kotemplate#autocmd_function)
    return s:autocmd_functions[g:kotemplate#autocmd_function]
  endif
  return s:autocmd_functions.inputlist
endfunction

function! s:make_project(project_dict, path) abort
  for [key, val] in items(a:project_dict)
    if type(val) == type('')
      let filepath = a:path . s:eval(substitute(key, '%%PROJECT%%', s:project_name, 'g'))
      noautocmd edit `=filepath`
      call kotemplate#load(val)
      let &l:fileencoding = g:kotemplate#fileencoding
      let &l:fileformat = g:kotemplate#fileformat
      noautocmd write
      bwipeout
    elseif type(val) == type({})
      let dirpath = s:add_path_separator(a:path . s:eval(substitute(key, '%%PROJECT%%', s:project_name, 'g')))
      if !isdirectory(dirpath)
        call mkdir(dirpath)
      endif
      call s:make_project(val, dirpath)
    endif
    unlet key val
  endfor
endfunction

function! s:add_path_separator(path) abort
  return strridx(a:path, '/') + 1 == len(a:path) ? a:path : (a:path . '/')
endfunction

let s:template_cache = []
function! s:gather_template_files() abort
  if !g:kotemplate#enable_template_cache || empty(s:template_cache)
    let s:template_cache = filter(split(globpath(
          \ g:kotemplate#dir . '**', '*'), "\n"), 'filereadable(v:val)')
  endif
  return copy(s:template_cache)
endfunction

function! s:suffix_filter(candidates) abort
  if has_key(g:kotemplate#filter.pattern, &filetype)
    return s:uniq(s:flatten(map(copy(g:kotemplate#filter.pattern[&filetype]),
          \ 'filter(copy(a:candidates), "v:val =~# " . string("\\." . v:val . "$"))'), 1))
  else
    return a:candidates
  endif
endfunction

function! s:glob_filter(candidates) abort
  if has_key(g:kotemplate#filter.pattern, &filetype)
    let dir = s:add_path_separator(g:kotemplate#dir)
    let files = map(s:flatten(map(copy(g:kotemplate#filter.pattern[&filetype]),
          \ 'split(globpath(dir . "**", v:val), "\n")'), 1),
          \ printf('substitute(v:val, "^%s", "", "g")', expand(dir)))
    return filter(a:candidates, 'match(files, v:val) != -1')
  else
    return a:candidates
  endif
endfunction

function! s:regex_filter(candidates) abort
  if has_key(g:kotemplate#filter.pattern, &filetype)
    return s:uniq(s:flatten(map(copy(g:kotemplate#filter.pattern[&filetype]),
          \ 'filter(copy(a:candidates), "v:val =~# " . string(v:val))'), 1))
  else
    return a:candidates
  endif
endfunction

function! s:get_filter_function() abort
  if type(g:kotemplate#filter.function) == type(function('function'))
    return g:kotemplate#filter.function
  elseif type(g:kotemplate#filter.function) == type('')
        \ && has_key(g:kotemplate#filter_functions, g:kotemplate#filter.function)
    return g:kotemplate#filter_functions[g:kotemplate#filter.function]
  endif
  return g:kotemplate#filter_functions.glob
endfunction

let g:kotemplate#filter.pattern = get(g:kotemplate#filter, 'pattern', {})
let g:kotemplate#filter.function = get(g:kotemplate#filter, 'function', {})
let g:kotemplate#filter_functions = {
      \ 'suffix': function('s:suffix_filter'),
      \ 'glob': function('s:glob_filter'),
      \ 'regex': function('s:regex_filter')
      \}

function! s:flatten(list, ...) abort
  let limit = a:0 > 0 ? a:1 : -1
  let memo = []
  if limit == 0
    return a:list
  endif
  let limit -= 1
  for Value in a:list
    let memo += type(Value) == type([]) ? s:flatten(Value, limit) : [Value]
    unlet! Value
  endfor
  return memo
endfunction

function! s:uniq(list) abort
  return s:uniq_by(a:list, 'v:val')
endfunction

function! s:uniq_by(list, f) abort
  let list = map(copy(a:list), printf('[v:val, %s]', a:f))
  let i = 0
  let seen = {}
  while i < len(list)
    let key = string(list[i][1])
    if has_key(seen, key)
      call remove(list, i)
    else
      let seen[key] = 1
      let i += 1
    endif
  endwhile
  return map(list, 'v:val[0]')
endfunction

function! s:eval(str) abort
  try
    return eval(a:str)
  catch /^Vim\%((\a\+)\)\=:E\%(15\|121\|492\): /
    return a:str
  endtry
endfunction

function! s:input(...) abort
  new
  cnoremap <buffer> <Esc> __KOTEMPLATE_CANCELED__<CR>
  let str = call('input', a:000)
  bwipeout!
  return str =~# '__KOTEMPLATE_CANCELED__$' ? 0 : str
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
