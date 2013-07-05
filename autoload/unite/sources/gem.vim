let s:save_cpo = &cpo
set cpo&vim

let s:unite_source = {
      \ 'name': 'gem',
      \ 'max_candidates': 30,
      \ 'is_volatile': 1,
      \ 'required_pattern_length': 1,
      \ }

let s:V = vital#of('vital') " TODO
let s:F = s:V.import('System.Filepath')
let s:S = s:V.import('Data.String')
let s:C = s:V.import('System.Cache')
let s:_helper_path = printf(
      \ '%s%sgem.rb',
      \ expand('<sfile>:p:h'),
      \ s:F.separator())
let s:_cache_path = s:C.getfilename('unite-gem', 'gems')

function! s:unite_source.gather_candidates(args, context)
  if !filereadable(s:_cache_path)
    call unite#util#system(
          \ printf('gem search > %s', s:_cache_path))
  endif
  let cmd = printf(
        \     'ruby %s %s %s',
        \     s:_helper_path,
        \     s:_cache_path,
        \     a:context.input)
  let result = s:S.chomp(unite#util#system(cmd))
  return map(
        \ eval(result),
        \ '{
        \ "word": v:val,
        \ "source": "gem",
        \ "kind": "command",
        \ "action__command": unite#sources#gem#commandize(v:val),
        \ }')
endfunction

" commandize('rails (3.0.3)') #=> 'VimProcBang gem install rails'
function! unite#sources#gem#commandize(name)
  return printf(
        \ '%s gem install %s',
        \ unite#util#has_vimproc() ? 'VimProcBang' : '!',
        \ substitute(a:name, ' .*', '', ''))
endfunction

function! unite#sources#gem#define()
  return executable('gem') ? s:unite_source : []
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
