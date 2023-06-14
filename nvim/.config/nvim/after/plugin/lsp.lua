local lsp = require("lsp-zero")

lsp.preset({
    name = "recommended",
})

lsp.ensure_installed({
    "gopls",
    "lua_ls",
    "pyright",
    "solidity",
    "tsserver",
    "rust_analyzer",
})

local cmp = require("cmp")
cmp.setup({
    mapping = {
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }
})

lsp.set_sign_icons({
    error = "E",
    warn = "W",
    hint = "H",
    info = "I"
})

lsp.on_attach(function(_, bufnr)
    lsp.default_keymaps({ buffer = bufnr })
    lsp.buffer_autoformat()

    local opts = { buffer = bufnr }
    local nmap = require("jero.keymap").nmap

    nmap("K", function() vim.lsp.buf.hover() end, opts)
    nmap("<leader>e", function() vim.diagnostic.open_float() end, opts)
    nmap("<leader>ca", function() vim.lsp.buf.code_action() end, opts)
    nmap("<leader>rn", function() vim.lsp.buf.rename() end, opts)
end)

require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())

lsp.configure("ocamllsp", {
    cmd = { "ocamllsp" },
    filetypes = { "ocaml", "ocaml.menhir", "ocaml.interface", "ocaml.ocamllex", "reason", "dune" },
    root_dir = require("lspconfig.util").root_pattern("*.opam", "esy.json", "package.json", ".git", "dune-project",
        "dune-workspace"),
})

lsp.configure("gopls", {
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

lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})
