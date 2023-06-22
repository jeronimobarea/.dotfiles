local telescope = require("telescope")

telescope.setup({
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
            "_build/",
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

telescope.load_extension("file_browser")
telescope.load_extension("dap")

local builtin = require("telescope.builtin")
local nmap = require("jero.keymap").nmap

nmap("<leader>ff", builtin.find_files)
nmap("<leader>fj", function()
    builtin.grep_string({ search = vim.fn.input("[GREP] |> ") })
end)
nmap("<leader>fk", builtin.buffers)
nmap("<leader>fh", builtin.diagnostics)
nmap("<leader>f;", builtin.lsp_references)
nmap("<leader>fl", "<cmd>:Telescope file_browser path=%:p:h<CR>", { noremap = true })
