" ============================================================================
" FILE: kotemplate.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" Last Modified: 2015 07/07
" DESCRIPTION: {{{
" descriptions.
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim

let g:kotemplate#dir = get(g:, 'kotemplate#dir', '~/.vim/template/')
let g:kotemplate#tag_actions = get(g:, 'kotemplate#tag_actions', [])
let g:kotemplate#projects = get(g:, 'kotemplate#projects', {})
let g:kotemplate#fileencoding = get(g:, 'kotemplate#fileencoding', 'utf-8')
let g:kotemplate#fileformat = get(g:, 'kotemplate#fileformat', 'unix')


function! kotemplate#load(template_path, ...) abort
  let template_file = expand(g:kotemplate#dir . a:template_path)
  if !filereadable(template_file)
    echoerr 'File not found:' template_file
    return
  endif
  exec (line('.') - 1) . 'r ' . template_file

  let tag_actions = type(g:kotemplate#tag_actions) == type({}) ?
        \ [g:kotemplate#tag_actions] : g:kotemplate#tag_actions
  for tag_action in tag_actions
    for [tag, Action] in items(tag_action)
      if type(Action) == type(function('function'))
        exec 'silent %s/' . tag . '/\=Action(tag)/ge'
      else
        exec 'silent %s/' . tag . '/\=s:eval(Action)/ge'
      endif
      unlet Action
    endfor
  endfor
  silent %s/<%=\(.\{-}\)%>/\=s:eval(submatch(1))/ge
  let i = 1
  for va_arg_action in a:000
    let tag = printf('<-ARG%d->', i)
    exec 'silent %s/' . tag . '/\=s:eval(va_arg_action)/ge'
    let i += 1
  endfor
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
  let nargs = len(split(split(a:cmdline, '\s*\\\@<!|\s*')[-1], '\s\+'))
  if nargs == 1 || (nargs == 2 && a:arglead !=# '')
    let candidates = g:kotemplate#filter.function(filter(split(globpath(
          \ g:kotemplate#dir . '**', '*'), "\n"), 'filereadable(v:val)'))
    return filter(map(candidates, printf("substitute(v:val, '^%s', '', 'g')",
          \ expand(g:kotemplate#dir))), 'stridx(tolower(v:val), tolower(a:arglead)) == 0')
  endif
endfunction


function! kotemplate#complete_project(arglead, cmdline, cursorpos) abort
  let nargs = len(split(split(a:cmdline, '\s*\\\@<!|\s*')[-1], '\s\+'))
  if nargs == 2 || (nargs == 3 && a:arglead !=# '')
    return filter(keys(g:kotemplate#projects), 'stridx(tolower(v:val), tolower(a:arglead)) == 0')
  endif
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
      let newpath = s:add_path_separator(a:path . s:eval(substitute(key, '%%PROJECT%%', s:project_name, 'g')))
      if !isdirectory(newpath)
        call mkdir(newpath)
      endif
      call s:make_project(val, newpath)
    endif
    unlet key val
  endfor
endfunction

function! s:add_path_separator(path) abort
  return strridx(a:path, '/') + 1 == len(a:path) ? a:path : (a:path . '/')
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
    let path = g:kotemplate#dir . '**'
    let files = s:flatten(map(copy(g:kotemplate#filter.pattern[&filetype]),
          \ 'split(globpath(path . "**", v:val), "\n")'), 1)
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

let g:kotemplate#filter = get(g:, 'kotemplate#filter', {
      \ 'pattern': {},
      \ 'function': function('s:glob_filter')
      \})
let g:kotemplate#filter_function = {
      \ 'suffix': function('s:suffix_filter'),
      \ 'glob': function('s:glob_filter'),
      \ 'regex': function('s:regex_filter'),
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


let &cpo = s:save_cpo
unlet s:save_cpo
