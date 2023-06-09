require("telescope").load_extension("lazygit")

vim.keymap.set('n', '<space>d;', require("telescope").extensions.lazygit.lazygit, {})

vim.cmd("autocmd BufEnter * lua require('lazygit.utils').project_root_dir()")
