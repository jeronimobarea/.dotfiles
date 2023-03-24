nnoremap <space>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <space>fj <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <space>fk <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <space>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
nnoremap <space>f; <cmd>lua require('telescope.builtin').lsp_references()<cr>

nnoremap <space>fl :Telescope file_browser path=%:p:h<cr>
