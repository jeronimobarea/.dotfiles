require("telescope").setup({
    pickers = {
        find_files = {
            hidden = true,
        },
    },
    defaults = {
        color_devicons = true,
        prompt_prefix = " => ",

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
            override_generic_sorter = true,
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
local nmap = require("jero.keymap").nmap

nmap("<space>ff", builtin.find_files)
nmap("<space>fj", function()
    builtin.grep_string({ search = vim.fn.input("[GREP] |> ") })
end)
nmap("<space>fk", builtin.buffers)
nmap("<space>fh", builtin.diagnostics)
nmap("<space>f;", builtin.lsp_references)
nmap("<space>fl", "<cmd>:Telescope file_browser path=%:p:h<CR>", { noremap = true })
