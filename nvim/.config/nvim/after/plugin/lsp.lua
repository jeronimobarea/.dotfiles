local lsp = require("lsp-zero")

lsp.preset({
    name = "recommended",
})

require("mason-lspconfig").setup({
    ensure_installed = {
        "gopls",
        "lua_ls",
        "pyright",
        "solidity",
        "tsserver",
        "rust_analyzer",
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

local lspconfig = require("lspconfig")

lspconfig.lua_ls.setup(lsp.nvim_lua_ls())

lspconfig.ocamllsp.setup({
    cmd = { "ocamllsp" },
    filetypes = { "ocaml", "ocaml.menhir", "ocaml.interface", "ocaml.ocamllex", "reason", "dune" },
    root_dir = require("lspconfig.util").root_pattern("*.opam", "esy.json", "package.json", ".git", "dune-project",
        "dune-workspace"),
})

lspconfig.gopls.setup({
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

local cmp = require("cmp")
local cmp_action = require("lsp-zero").cmp_action()

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
    sources = {
        { name = "path" },
        { name = "nvim_lsp" },
        { name = "buffer",  keyword_length = 3 },
        { name = "luasnip", keyword_length = 2 },
    },
    mapping = {
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<C-f>"] = cmp_action.luasnip_jump_forward(),
        ["<C-b>"] = cmp_action.luasnip_jump_backward(),
    }
})

vim.diagnostic.config({
    virtual_text = true
})
