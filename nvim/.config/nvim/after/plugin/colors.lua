vim.opt.termguicolors = true

-- REMOVE BACKGROUND
vim.cmd("hi Normal guibg=none")
vim.cmd("au ColorScheme * hi Normal ctermbg=none guibg=none")
vim.cmd("au ColorScheme myspecialcolors hi Normal ctermbg=red guibg=red")
vim.cmd.colorscheme("gruvbox")
