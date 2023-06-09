set completeopt=menu,menuone,noselect
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']

if executable('opam')
  let g:opamshare=substitute(system('opam var share'),'\n$','','''')
  if isdirectory(g:opamshare."/merlin/vim")
    execute "set rtp+=" . g:opamshare."/merlin/vim"
  endif
endif
" vim-go stuff

" let g:go_gopls_enabled = 0
" let g:go_code_completion_enabled = 0
" let g:go_auto_sameids = 0
" let g:go_fmt_autosave = 0
" let g:go_def_mapping_enabled = 0
" let g:go_diagnostics_enabled = 0
" let g:go_echo_go_info = 0
" let g:go_metalinter_enabled = 0
