require 'nvim-treesitter.configs'.setup {
    ensure_installed = { "lua", "go", "rust", "python", "json", "yaml" },
    sync_install = false,
    indent = {
        enable = true,
    },
    highlight = {
        enable = true,
    },
    incremental_selection = {
        enable = true,
    },
    textobjects = {
        enable = true,
    }
}
