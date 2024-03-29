local nmap = require("jero.keymap").nmap
local tmap = require("jero.keymap").tmap

vim.g.mapleader = " "

tmap("<Esc>", "<C-\\><C-n>")
nmap("<leader>t", "<cmd>belowright 20split term://zsh<cr>")
nmap("<leader>q", "<cmd>:q<cr>")
nmap("<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/jero/packer.lua<CR>")
nmap("<leader><leader>", function()
    vim.cmd("so")
end)
