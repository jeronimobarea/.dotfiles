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
    },
    extensions = {
        file_browser = {
            hidden = true,
            grouped = true,
        }
    }
}

require("telescope").load_extension("file_browser")

local builtin = require('telescope.builtin')
local bind = vim.keymap.set

bind('n', '<space>ff', builtin.find_files, {})
bind('n', '<space>fj', builtin.live_grep, {})
bind('n', '<space>fk', builtin.buffers, {})
bind('n', '<space>fh', builtin.help_tags, {})
bind('n', '<space>f', builtin.lsp_references, {})

bind('n', '<space>fl', require("telescope").extensions.file_browser.file_browser, {})
