nnoremap <leader>ga :Git fetch --all<CR>
nnoremap <leader>grum :Git rebase upstream/master<CR>
nnoremap <leader>grom :Git rebase origin/master<CR>

nmap <leader>gh :diffget //3<CR>
nmap <leader>gu :diffget //2<CR>
nmap <leader>gs :G<CR>

" setup mapping to call :LazyGit
nnoremap <silent> <space>gg :LazyGit<CR>

autocmd BufEnter * :lua require('lazygit.utils').project_root_dir()

