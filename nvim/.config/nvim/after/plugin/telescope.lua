require("telescope").setup({
    pickers = {
        find_files = {
            hidden = true,
        },
    },
    defaults = {
        color_devicons = true,

        prompt_prefix = "|> ",

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
        fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
        },
        file_browser = {
            hidden = true,
            grouped = true,
        }
    }
})

require("telescope").load_extension("file_browser")

local builtin = require("telescope.builtin")
local bind = vim.keymap.set

bind("n", "<space>ff", builtin.find_files)
bind("n", "<space>fj", function()
    builtin.grep_string({ search = vim.fn.input("[GREP] |> ") })
end)
bind("n", "<space>fk", builtin.buffers)
bind("n", "<space>fh", builtin.diagnostics)
bind("n", "<space>f;", builtin.lsp_references)
bind("n", "<space>fl", "<cmd>:Telescope file_browser path=%:p:h<CR>", { noremap = true })
