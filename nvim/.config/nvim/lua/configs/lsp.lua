local lsp = require("lsp-zero")

lsp.preset({
    name = 'recommended',
})

lsp.ensure_installed({
    'gopls',
    'lua_ls',
    'pyright',
    'solidity',
    'tsserver',
    'rust_analyzer',
    'ocamllsp',
})

-- Fix Undefined global 'vim'
lsp.configure('lua_ls', {
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            }
        }
    }
})

lsp.configure('ocamllsp', {
    cmd = { "ocamllsp" },
    filetypes = { "ocaml", "ocaml.menhir", "ocaml.interface", "ocaml.ocamllex", "reason", "dune" },
    root_dir = require('lspconfig.util').root_pattern("*.opam", "esy.json", "package.json", ".git", "dune-project",
        "dune-workspace"),
})

lsp.configure('gopls', {
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
            buildFlags = { "-tags=integration" },
        },
    },
})

local cmp = require('cmp')

cmp.setup({
    mapping = {
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
    }
})

lsp.on_attach(function(client, bufnr)
    lsp.default_keymaps({ buffer = bufnr })
    local opts = { buffer = bufnr, remap = false }
    local bind = vim.keymap.set

    bind("n", "K", function() vim.lsp.buf.hover() end, opts)
    bind("n", "<leader>e", function() vim.diagnostic.open_float() end, opts)
    bind("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
    bind("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
end)

lsp.set_preferences({
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})


lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})
