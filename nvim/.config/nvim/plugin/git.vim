nnoremap <silent> <space>f; :LazyGit<CR>

autocmd BufEnter * :lua require('lazygit.utils').project_root_dir()

