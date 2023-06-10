local bind = vim.keymap.set

vim.g.mapleader = " "

bind("v", "J", ":m '>+1<CR>gv=gv")
bind("v", "K", ":m '<-2<CR>gv=gv")

bind('n', '<space>t', '<cmd>belowright 20split term://zsh<cr>')
bind('n', '<space>q', '<cmd>:q<cr>')
bind('n', '<Esc>', '<C-\\><C-n>')

bind("n", "<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/configs/packer.lua<CR>")
bind("n", "<leader><leader>", function()
    vim.cmd("so")
end)
