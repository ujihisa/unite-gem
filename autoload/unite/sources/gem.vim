let s:save_cpo = &cpo
set cpo&vim

let s:unite_source = {
      \ 'name': 'gem',
      \ 'max_candidates': 30,
      \ 'is_volatile': 1,
      \ 'required_pattern_length': 1,
      \ }

function! s:unite_source.gather_candidates(args, context)
  return map(
        \ split(
        \   unite#util#system(printf(
        \     'gem search %s -r',
        \     a:context.input)),
        \   "\n"),
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
