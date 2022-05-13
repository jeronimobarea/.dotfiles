require("telescope").setup {
    pickers = {
        find_files = {
            hidden = true,
        },
    },
    defaults = {
        color_devicons = true,
        set_env = { ["COLORTERM"] = "truecolor" },
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
        file_ignore_patterns = {
            "/.git/*",
            "go.sum",
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
        },
    },
}

require("telescope").load_extension("fzy_native")
require("telescope").load_extension("file_browser")

