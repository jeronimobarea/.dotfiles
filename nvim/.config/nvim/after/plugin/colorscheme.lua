local cmd = vim.cmd

vim.opt.termguicolors = true

-- REMOVE BACKGROUND
cmd("hi Normal guibg=none")
cmd("au ColorScheme * hi Normal ctermbg=none guibg=none")
cmd("au ColorScheme myspecialcolors hi Normal ctermbg=red guibg=red")
cmd.colorscheme("gruvbox")
