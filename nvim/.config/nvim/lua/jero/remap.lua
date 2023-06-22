local nmap = require("jero.keymap").nmap

vim.g.mapleader = " "

nmap("<leader>t", "<cmd>belowright 20split term://zsh<cr>")
nmap("<leader>q", "<cmd>:q<cr>")
nmap("<Esc>", "<C-\\><C-n>")

nmap("<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/configs/packer.lua<CR>")
nmap("<leader><leader>", function()
    vim.cmd("so")
end)
