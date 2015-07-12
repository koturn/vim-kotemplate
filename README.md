vim-kotemplate
==============

koturn's Template loader for Vim.


## Sample configuration

Don't think, feel!

```VimL
function! s:filter_function(candidates)
  return g:kotemplate#filter_function.glob(a:candidates)
endfunction
function s:get_filename_camel2capital(tag)
  let l:basefilename = fnamemodify(expand('%'), ':t:r')
  return l:basefilename == '' ? a:tag : toupper(substitute(l:basefilename, '.\@<=\(\u\)', '_\l\1', 'g'))
endfunction
  function s:move_cursor(tag)
    if getline(line('$')) == ''
      let l:pos = getpos('.')
      normal! G"_ddgg
      call setpos('.', l:pos)
    endif
    if search(a:tag)
      normal! "_da>
    endif
    return ''
  endfunction

let g:kotemplate#filter = {
      \ 'pattern': {
      \   'c': ['*.c', '*.h'],
      \   'cpp': ['*.c', '*.cc', '*.cpp', '*.cxx', '*.h', '*.hpp'],
      \   'cs': ['*.cs'],
      \   'html': ['*.html'],
      \   'java': ['*.java'],
      \   'javascript': ['*.javascript'],
      \   'markdown': ['*.md'],
      \   'python': ['*.py'],
      \   'ruby': ['*.rb'],
      \   'vim': ['*.vim'],
      \   'xml': ['*.xml'],
      \ },
      \ 'function': function('s:filter_function')
      \}
endfunction
let g:kotemplate#enable_autocmd = 1
let g:kotemplate#auto_filetypes = keys(g:kotemplate#filter.pattern)
let g:kotemplate#dir = '~/github/kotemplate/'
let g:kotemplate#tag_actions = [{
      \ '<+AUTHOR+>': 'Your name',
      \ '<+MAIL_ADDRESS+>': 'xxxx.yyyy.zzzz@mail.com',
      \ '<+DATE+>': "escape(strftime('%Y %m/%d'), '/')",
      \ '<+YEAR+>': "escape(strftime('%Y'), '/')",
      \ '<+FILE+>': "fnamemodify(expand('%'), ':t')",
      \ '<+FILEBASE+>': function('s:get_filename_camel2capital'),
      \ '<+FILE_CAPITAL+>': function('s:get_filename_camel2capital'),
      \}, {
      \ '<+CURSOR+>': function('s:move_cursor'),
      \}]
let s:vim_project_expr = 'fnamemodify(substitute(%%PROJECT%%, "^vim-", "", "g"), ":t:r") . ".vim"'
let g:kotemplate#projects = {
      \ 'vim': {
      \   'autoload' : {s:vim_project_expr : 'Vim/autoload.vim'},
      \   'plugin' : {s:vim_project_expr : 'Vim/plugin.vim'},
      \   'README.md': 'Markdown/ReadMe.md',
      \   'LICENSE': 'License/MIT'
      \ }, 'java': {
      \   'src': {'Main.java': 'Java/Main.java'},
      \   'bin': {},
      \   'build.xml': 'Java/build.xml'
      \ }, 'web': {
      \   'index.html': 'HTML/html5.html',
      \   'css': {},
      \   'js': 'JavaScript/module.js'
      \ }
      \}
```


## LICENSE

This software is released under the MIT License, see [LICENSE](LICENSE).
