" ============================================================================
" FILE: kotemplate.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" koturn's template loader.
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim

" {{{ Global variables
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
" }}}

" {{{ Constants
let s:t_number = type(0)
let s:t_string = type('')
let s:t_func = type(function('function'))
let s:t_list = type([])
let s:t_dict = type({})
" }}}

" {{{ Script local variables
let s:template_cache = []
" }}}

function! kotemplate#load(template_path, ...) abort " {{{
  let template_file = expand(s:add_path_separator(g:kotemplate#dir) . a:template_path)
  if !filereadable(template_file)
    echoerr 'File not found:' template_file
    return
  endif
  let [curpos, line, file_text] = [getcurpos(), getline('.'), readfile(template_file)]
  if len(file_text) == 0
    return
  endif
  let line_parts = [line[: curpos[2] - 1], line[curpos[2] :]]
  let line_end = curpos[1] + len(file_text) - 1
  call setline(line('.'), file_text)
  call setline(curpos[1], line_parts[0] . getline(curpos[1]))
  call setline(line_end, getline(line_end) . line_parts[1])
  let tag_actions = type(g:kotemplate#tag_actions) == s:t_dict ?
        \ [g:kotemplate#tag_actions] : g:kotemplate#tag_actions
  for tag_action in tag_actions
    for [tag, Action] in items(tag_action)
      execute 'silent keepjumps keeppatterns %s/' . tag
            \ . '/\=' (type(Action) == s:t_func ? 'Action(tag)' : 's:eval(Action)') '/ge'
      unlet Action
    endfor
  endfor
  let i = 1
  for va_arg_action in a:000
    let tag = printf('<-ARG%d->', i)
    execute 'silent keepjumps keeppatterns %s/' . tag . '/\=s:eval(va_arg_action)/ge'
    let i += 1
  endfor
endfunction " }}}

function! kotemplate#auto_action() abort " {{{
  if g:kotemplate#enable_autocmd
    if &filetype ==# ''
      autocmd! KoTemplate FileType <buffer>
      autocmd KoTemplate FileType <buffer>  call s:auto_action()
    else
      call s:auto_action()
    endif
  endif
endfunction " }}}

function! kotemplate#make_project(has_bang, project_name, template_project_name) abort " {{{
  let project = has_key(g:kotemplate#projects, a:template_project_name) ?
        \ g:kotemplate#projects[a:template_project_name] : {}
  if !isdirectory(a:project_name)
    call mkdir(a:project_name)
  endif
  let s:project_name = string(a:project_name)
  noautocmd call s:make_project(a:has_bang, project, s:add_path_separator(a:project_name))
endfunction " }}}

function! kotemplate#complete_load(arglead, cmdline, cursorpos) abort " {{{
  let shellslash = &shellslash
  set shellslash
  let nargs = a:cmdline ==# '' ? 1 : len(split(split(a:cmdline, '[^\\]\zs|')[-1], '\s\+'))
  if nargs == 1 || (nargs == 2 && a:arglead !=# '')
    let candidates = s:get_filter_function()(map(s:gather_template_files(),
          \ printf('substitute(v:val, "^%s", "", "g")',
          \ expand(s:add_path_separator(g:kotemplate#dir)))))
    let &shellslash = shellslash
    let _arglead = tolower(a:arglead)
    return filter(candidates, '!stridx(tolower(v:val), _arglead)')
  endif
  let &shellslash = shellslash
endfunction " }}}

function! kotemplate#complete_project(arglead, cmdline, cursorpos) abort " {{{
  let nargs = len(split(split(a:cmdline, '[^\\]\zs|')[-1], '\s\+'))
  if nargs == 2 || (nargs == 3 && a:arglead !=# '')
    let _arglead = tolower(a:arglead)
    return filter(keys(g:kotemplate#projects), '!stridx(tolower(v:val), _arglead)')
  endif
endfunction " }}}


function! s:auto_action() abort " {{{
  autocmd! KoTemplate FileType <buffer>
  if !count(g:kotemplate#auto_filetypes, &filetype) || filereadable(expand('%:p'))
    return
  endif
  autocmd KoTemplate User TemplateLoaded call s:clear_undo() | autocmd! KoTemplate User TemplateLoaded
  call s:get_autocmd_function()()
endfunction " }}}

function! s:auto_action_excommand() abort " {{{
  call feedkeys(":\<C-u>KoTemplateLoad ", 'n')
  silent doautocmd KoTemplate User TemplateLoaded
endfunction " }}}

function! s:auto_action_rawinput() abort " {{{
  let input = s:input('Input template file name> ', '', 'customlist,kotemplate#complete_load')
  redraw!
  if type(input) != s:t_number
    call kotemplate#load(input)
    silent doautocmd KoTemplate User TemplateLoaded
  endif
endfunction " }}}

function! s:auto_action_getchar() abort " {{{
  let [template_files, from, to, fileidx] = [kotemplate#complete_load('', '', 0), 0, g:kotemplate#n_choises - 1, 1]
  let n_choises = g:kotemplate#n_choises > 9 ? 9 : g:kotemplate#n_choises
  echo "Select template file to load. (Input nothing if you don't want to load template file)"
  while from < len(template_files)
    let [i, msg] = [1, '']
    while i <= n_choises && fileidx - 1 < len(template_files)
      let msg .= printf("  %d. %s\n", i, template_files[from + i - 1])
      let fileidx += 1
      let i += 1
    endwhile
    echo msg . '> '
    let ch = getchar()
    if ch == char2nr("\<Esc>")
      return
    endif
    let nr = ch + from - char2nr('0') - 1
    if from <= nr && nr <= to && nr < len(template_files)
      call kotemplate#load(template_files[nr])
      silent doautocmd KoTemplate User TemplateLoaded
      return
    endif
    let from += n_choises
    let to += n_choises
  endwhile
endfunction " }}}

function! s:auto_action_input() abort " {{{
  let [template_files, from, to, fileidx] = [kotemplate#complete_load('', '', 0), 0, g:kotemplate#n_choises - 1, 1]
  echo "Select template file to load. (Input nothing if you don't want to load template file)"
  while from < len(template_files)
    let [i, msg] = [1, '']
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
        silent doautocmd KoTemplate User TemplateLoaded
        return
      endif
    elseif type(input) == s:t_number
      return
    else
      echo "\n"
    endif
    let from += g:kotemplate#n_choises
    let to += g:kotemplate#n_choises
  endwhile
endfunction " }}}

function! s:auto_action_inputlist() abort " {{{
  let [template_files, from, to, fileidx] = [kotemplate#complete_load('', '', 0), 0, g:kotemplate#n_choises - 1, 1]
  let msg = "Select template file to load. (Input nothing if you don't want to load template file)"
  let choises = insert(template_files[from : to], msg)
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
      silent doautocmd KoTemplate User TemplateLoaded
      return
    endif
    let from += g:kotemplate#n_choises
    let to += g:kotemplate#n_choises
    let choises[0] = ''
  endwhile
endfunction " }}}

function! s:auto_action_unite() abort " {{{
  Unite kotemplate
  silent doautocmd KoTemplate User TemplateLoaded
endfunction " }}}

function! s:auto_action_denite() abort " {{{
  Denite kotemplate
  silent doautocmd KoTemplate User TemplateLoaded
endfunction " }}}

function! s:auto_action_ctrlp() abort " {{{
  if has('vim_starting')
    autocmd KoTemplate VimEnter * wincmd w | autocmd! KoTemplate VimEnter *
  endif
  call ctrlp#init(ctrlp#kotemplate#id())
  silent doautocmd KoTemplate User TemplateLoaded
endfunction " }}}

function! s:auto_action_fzf() abort " {{{
  call fzf#run(fzf#kotemplate#option())
  silent doautocmd KoTemplate User TemplateLoaded
endfunction " }}}

function! s:auto_action_alti() abort " {{{
  call alti#init(alti#kotemplate#define())
  silent doautocmd KoTemplate User TemplateLoaded
endfunction " }}}

function! s:auto_action_milqi() abort " {{{
  call milqi#candidate_first(milqi#kotemplate#define())
  silent doautocmd KoTemplate User TemplateLoaded
endfunction " }}}

let s:autocmd_functions = { " {{{
      \ 'excommand': function('s:auto_action_excommand'),
      \ 'getchar': function('s:auto_action_getchar'),
      \ 'rawinput': function('s:auto_action_rawinput'),
      \ 'input': function('s:auto_action_input'),
      \ 'inputlist': function('s:auto_action_inputlist'),
      \ 'unite': function('s:auto_action_unite'),
      \ 'denite': function('s:auto_action_denite'),
      \ 'ctrlp': function('s:auto_action_ctrlp'),
      \ 'fzf': function('s:auto_action_fzf'),
      \ 'alti': function('s:auto_action_alti'),
      \ 'milqi': function('s:auto_action_milqi')
      \} " }}}

function! s:get_autocmd_function() abort " {{{
  if has_key(s:autocmd_functions, g:kotemplate#autocmd_function)
    return s:autocmd_functions[g:kotemplate#autocmd_function]
  else
    return s:autocmd_functions.inputlist
  endif
endfunction " }}}

function! s:make_project(has_bang, project_dict, path) abort " {{{
  for [key, val] in items(a:project_dict)
    if type(val) == s:t_string
      let filepath = a:path . s:eval(substitute(key, '%%PROJECT%%', s:project_name, 'g'))
      if filereadable(filepath)
        if a:has_bang
          call delete(filepath)
        else
          echohl Error
          echomsg 'File:' filepath 'is already exists'
          echohl None
          unlet key val
          continue
        endif
      endif
      edit `=filepath`
      call kotemplate#load(val)
      let [&fileencoding, &fileformat, dir] = [g:kotemplate#fileencoding, g:kotemplate#fileformat, fnamemodify(filepath, ':p:h')]
      if !isdirectory(dir)
        call mkdir(iconv(dir, &encoding, &termencoding), 'p')
      endif
      write
      bwipeout
    elseif type(val) == s:t_dict
      let dirpath = s:add_path_separator(a:path . s:eval(substitute(key, '%%PROJECT%%', s:project_name, 'g')))
      if !isdirectory(dirpath)
        call mkdir(dirpath, 'p')
      endif
      call s:make_project(a:has_bang, val, dirpath)
    endif
    unlet key val
  endfor
endfunction " }}}

function! s:add_path_separator(path) abort " {{{
  return a:path[-1 :] ==# '/' ? a:path : (a:path . '/')
endfunction " }}}

function! s:gather_template_files() abort " {{{
  if !g:kotemplate#enable_template_cache || empty(s:template_cache)
    let s:template_cache = filter(extend(
          \ split(globpath(g:kotemplate#dir . '**', '*', 1), "\n"),
          \ split(globpath(g:kotemplate#dir . '**', '.*', 1), "\n")),
          \ 'filereadable(v:val)')
  endif
  return copy(s:template_cache)
endfunction " }}}

function! s:suffix_filter(candidates) abort " {{{
  if has_key(g:kotemplate#filter.pattern, &filetype)
    return s:uniq(s:flatten(map(copy(g:kotemplate#filter.pattern[&filetype]),
          \ 'filter(copy(a:candidates), "v:val =~# " . string("\\." . v:val . "$"))'), 1))
  else
    return a:candidates
  endif
endfunction " }}}

function! s:glob_filter(candidates) abort " {{{
  if has_key(g:kotemplate#filter.pattern, &filetype)
    let dir = s:add_path_separator(g:kotemplate#dir)
    let files = map(s:flatten(map(copy(g:kotemplate#filter.pattern[&filetype]),
          \ 'split(globpath(dir . "**", v:val, 1), "\n")'), 1),
          \ printf('substitute(v:val, "^%s", "", "g")', expand(dir)))
    return filter(a:candidates, 'match(files, v:val) != -1')
  else
    return a:candidates
  endif
endfunction " }}}

function! s:regex_filter(candidates) abort " {{{
  if has_key(g:kotemplate#filter.pattern, &filetype)
    return s:uniq(s:flatten(map(copy(g:kotemplate#filter.pattern[&filetype]),
          \ 'filter(copy(a:candidates), "v:val =~# " . string(v:val))'), 1))
  else
    return a:candidates
  endif
endfunction " }}}

function! s:get_filter_function() abort " {{{
  if type(g:kotemplate#filter.function) == s:t_func
    return g:kotemplate#filter.function
  elseif type(g:kotemplate#filter.function) == s:t_string
        \ && has_key(g:kotemplate#filter_functions, g:kotemplate#filter.function)
    return g:kotemplate#filter_functions[g:kotemplate#filter.function]
  else
    return g:kotemplate#filter_functions.glob
  endif
endfunction " }}}

let g:kotemplate#filter.pattern = get(g:kotemplate#filter, 'pattern', {})
let g:kotemplate#filter.function = get(g:kotemplate#filter, 'function', {})
let g:kotemplate#filter_functions = {
      \ 'suffix': function('s:suffix_filter'),
      \ 'glob': function('s:glob_filter'),
      \ 'regex': function('s:regex_filter')
      \}

function! s:flatten(list, ...) abort " {{{
  let limit = a:0 > 0 ? a:1 : -1
  let memo = []
  if limit == 0
    return a:list
  endif
  let limit -= 1
  for Value in a:list
    let memo += type(Value) == s:t_list ? s:flatten(Value, limit) : [Value]
    unlet! Value
  endfor
  return memo
endfunction " }}}

function! s:uniq(list) abort " {{{
  return s:uniq_by(a:list, 'v:val')
endfunction " }}}

function! s:uniq_by(list, f) abort " {{{
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
endfunction " }}}

function! s:eval(str) abort " {{{
  try
    return eval(a:str)
  catch /^Vim(return)\=:E\%(\d\+\): /
    return a:str
  endtry
endfunction " }}}

function! s:clear_undo() abort " {{{
  if &modifiable
    let save_undolevels = &l:undolevels
    setlocal undolevels=-1
    execute "normal! a \<BS>\<Esc>"
    setlocal nomodified
    let &l:undolevels = save_undolevels
  endif
endfunction " }}}

function! s:input(...) abort " {{{
  let [filetype, dummy] = [&filetype, '__KOTEMPLATE_CANCELED__']
  new
  noautocmd let &filetype = filetype
  execute 'cnoremap <buffer> <Esc>' dummy . '<CR>'
  try
    let input = call('input', a:000)
    return input[-len(dummy) :] ==# dummy ? 0 : input
  catch /^Vim:Interrupt$/
    return -1
  finally
    bwipeout!
  endtry
endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo
