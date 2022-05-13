require 'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all"
    ensure_installed = { "lua", "go", "rust", "python", "json", "yaml" },
    sync_install = false,
    indent = {
        enable = true,
    },
    highlight = {
        -- `false` will disable the whole extension
        enable = true,
    },
    incremental_selection = {
        enable = true,
    },
    textobjects = {
        enable = true,
    }
}
