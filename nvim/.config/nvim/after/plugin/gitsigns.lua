require("gitsigns").setup({
    signs = {
        add       = { text = "+" },
        change    = { text = "~" },
        delete    = { text = "-" },
        untracked = { text = "?" },
    },
    current_line_blame_opts = {
        delay = 100,
    },
    current_line_blame = true,
})
