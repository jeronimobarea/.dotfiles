nnoremap <silent> <space>d; :LazyGit<CR>

autocmd BufEnter * :lua require('lazygit.utils').project_root_dir()

