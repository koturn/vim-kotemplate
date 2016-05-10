vim-kotemplate
==============

koturn's Template loader for Vim.


## Usage

This plugin is template loader and provides two commands, ```:KoTemplateLoad```
and ```:KoTemplateMakeProject```. ```:KoTemplateLoad``` is a command to load a
template file. ```:KoTemplateMakeProject``` is a command to make a project,
which means directories and files in them.

Both of two commands needs some configuration. See following sample!


#### Sample configuration

Don't think, feel!

```vim
function! s:get_filename(tag) abort
  let l:filename = fnamemodify(expand('%'), ':t')
  return l:filename == '' ? a:tag : l:filename
endfunction
function! s:get_basefilename(tag) abort
  let l:basefilename = fnamemodify(expand('%'), ':t:r')
  return l:basefilename == '' ? a:tag : l:basefilename
endfunction
function! s:get_filename_camel2capital(tag) abort
  let l:basefilename = fnamemodify(expand('%'), ':t:r')
  let l:basefilename = toupper(substitute(l:basefilename, '.\@<=\(\u\)', '_\l\1', 'g'))
  return l:basefilename == '' ? a:tag : l:basefilename
endfunction
function! s:get_filename_snake2pascal(tag) abort
  let l:basefilename = fnamemodify(expand('%'), ':t:r')
  let l:basefilename = substitute(l:basefilename, '\(^\l\)', '\u\1', '')
  let l:basefilename = substitute(l:basefilename, '_\(\l\)', '\u\1', 'g')
  return l:basefilename == '' ? a:tag : l:basefilename
endfunction
function! s:move_cursor(tag) abort
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
      \ 'function': 'glob'
      \}
let g:kotemplate#enable_autocmd = 1
let g:kotemplate#auto_filetypes = keys(g:kotemplate#filter.pattern)
let g:kotemplate#autocmd_function = 'input'
let g:kotemplate#dir = '~/.vim/template/'
let g:kotemplate#tag_actions = [{
      \ '<+AUTHOR+>': 'koturn',
      \ '<+MAIL_ADDRESS+>': 'xxxx.yyyy.zzzz@gmail.com',
      \ '<+DATE+>': "strftime('%Y %m/%d')",
      \ '<+YEAR+>': "strftime('%Y')",
      \ '<+FILE+>': function('s:get_filename'),
      \ '<+FILEBASE+>': function('s:get_basefilename'),
      \ '<+FILE_CAPITAL+>': function('s:get_filename_camel2capital'),
      \ '<+FILE_PASCAL+>': function('s:get_filename_snake2pascal'),
      \ '<+DIR+>': 'split(expand("%:p:h"), "/")[-1]',
      \ '<%=\(.\{-}\)%>': 'eval(submatch(1))',
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


## Installation

###### With [dein.vim](https://github.com/Shougo/dein.vim).

```vim
call dein#add('koturn/vim-kotemplate', {
      \ 'depends': ['unite.vim', 'ctrlp.vim', 'alti.vim', 'vim-milqi'],
      \ 'on_cmd': [
      \   'KoTemplateLoad',
      \   'KoTemplateMakeProject',
      \   'CtrlPKoTemplate',
      \   'AltiKoTemplate',
      \   'MilqiKoTemplate',
      \   'FZFKoTemplate',
      \ ],
      \ 'on_source': 'unite.vim',
      \ 'on_func': 'kotemplate'
      \})

" Dependent plugins (optional)
call dein#add('Shougo/unite.vim')
call dein#add('koturn/vim-kotemplate')
call dein#add('LeafCage/alti.vim')
call dein#add('kamichidu/vim-milqi')

" ...

if dein#tap('vim-kotemplate')  " {{{
  augroup KoTemplate
    autocmd!
    autocmd BufNewFile * call neobundle#commands#source('vim-kotemplate') | call kotemplate#auto_action()
  augroup END
endif
" }}}
```

###### With [neobundle.vim](https://github.com/Shougo/neobundle.vim).

```vim
NeoBundle 'koturn/vim-kotemplate'
```

If you want to use ```:NeoBundleLazy``` by any means, write following code in your .vimrc.

```vim
NeoBundle 'koturn/vim-kotemplate', {
      \ 'depends': [
      \   'Shougo/unite.vim',
      \   'ctrlpvim/ctrlp.vim',
      \   'LeafCage/alti.vim',
      \   'kamichidu/vim-milqi'
      \ ],
      \ 'on_cmd' : [
      \   'KoTemplateLoad',
      \   'KoTemplateMakeProject',
      \   'CtrlPKoTemplate',
      \   'AltiKoTemplate',
      \   'MilqiKoTemplate',
      \   'FZFKoTemplate',
      \ ],
      \ 'on_source': 'unite.vim',
      \ 'on_func': 'kotemplate'
      \}

" ...

if neobundle#tap('vim-kotemplate')  " {{{
  augroup KoTemplate
    autocmd!
    autocmd BufNewFile * call neobundle#commands#source('vim-kotemplate') | call kotemplate#auto_action()
  augroup END
  call neobundle#untap()
endif
" }}}
```

###### With [Vundle](https://github.com/VundleVim/Vundle.vim).

```vim
Plugin 'koturn/vim-kotemplate'
```

###### With [vim-plug](https://github.com/junegunn/vim-plug).

```vim
Plug 'koturn/vim-kotemplate'
```

###### Manual install

If you don't want to use plugin manager, put files and directories on
```~/.vim/```, or ```%HOME%/vimfiles/``` on Windows.


## Dependent plugins

#### Optional

Following plugins aren't indispensable. But this plugin work with them.

- [Shougo/unite.vim](https://github.com/Shougo/unite.vim)
- [ctrlpvim/ctrlp.vim](https://github.com/ctrlpvim/ctrlp.vim)
- [LeafCage/alti.vim](https://github.com/LeafCage/alti.vim)
- [kamichidu/vim-milqi](https://github.com/kamichidu/vim-milqi)


## LICENSE

This software is released under the MIT License, see [LICENSE](LICENSE).
