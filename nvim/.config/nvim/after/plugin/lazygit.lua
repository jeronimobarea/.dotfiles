vim.keymap.set('n', '<space>d;', '<cmd>:LazyGit<CR>', {})

local autocmd = vim.api.nvim_create_autocmd

autocmd('BufEnter', {
    callback = function()
        require('lazygit.utils').project_root_dir()
    end
})
