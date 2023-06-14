vim.keymap.set("n", "<space>d;", "<cmd>:LazyGit<CR>")

vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        require("lazygit.utils").project_root_dir()
    end
})
