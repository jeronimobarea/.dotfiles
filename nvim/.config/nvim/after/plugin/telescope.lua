require("telescope").setup {
    pickers = {
        find_files = {
            hidden = true,
        },
    },
    defaults = {
        file_ignore_patterns = {
            ".git/",
            "target/",
            "go.sum",
            "node_modules/",
        },
        vimgrep_arguments = {
            "rg",
            "--hidden",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
        },
    },
    extensions = {
        file_browser = {
            hidden = true,
            grouped = true,
        }
    }
}

local builtin = require('telescope.builtin')
local bind = vim.keymap.set

bind('n', '<space>ff', builtin.find_files, {})
bind('n', '<space>fj', builtin.live_grep, {})
bind('n', '<space>fk', builtin.buffers, {})
bind('n', '<space>fh', builtin.help_tags, {})
bind('n', '<space>f', builtin.lsp_references, {})

vim.api.nvim_set_keymap(
    "n",
    "<space>fl",
    "<cmd>:Telescope file_browser path=%:p:h<CR>",
    { noremap = true }
)
