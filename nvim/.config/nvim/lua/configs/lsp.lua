require("mason").setup()
require("mason-lspconfig").setup {
    automatic_installation = true,
}

local cmp = require("cmp")
local source_mapping = {
    buffer = "[Buffer]",
    nvim_lsp = "[LSP]",
    nvim_lua = "[Lua]",
    path = "[Path]",
}

-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
capabilities.textDocument.completion.completionItem.snippetSupport = true

local lspkind = require("lspkind")

cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    formatting = {
        format = function(entry, vim_item)
            vim_item.kind = lspkind.presets.default[vim_item.kind]
            local menu = source_mapping[entry.source.name]
            vim_item.menu = menu
            return vim_item
        end,
    },
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
    }),
})

-- Mappings.
NnoremapGlobal('<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>')
NnoremapGlobal('[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
NnoremapGlobal(']d', '<cmd>lua vim.diagnostic.goto_next()<CR>')
NnoremapGlobal('<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    Nnoremap('gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
    Nnoremap('gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
    Nnoremap('K', '<cmd>lua vim.lsp.buf.hover()<CR>')
    Nnoremap('gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
    Nnoremap('<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>')
    Nnoremap('<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>')
    Nnoremap('<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>')
    Nnoremap('<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>')
    Nnoremap('<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
    Nnoremap('<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
    Nnoremap('<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
    Nnoremap('gr', '<cmd>lua vim.lsp.buf.references()<CR>')
    -- Nnoremap('<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>')
end


local servers = { 'pyright', 'solidity', 'tsserver', 'ocamllsp' }
for _, lsp in pairs(servers) do
    require("lspconfig")[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

require("lspconfig")["lua_ls"].setup {
    on_attach = on_attach,
    capabilities = capabilities,

    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
        },
    },
}

require("lspconfig")["rust_analyzer"].setup {
    on_attach = on_attach,
    capabilities = capabilities,

    cmd = { "rustup", "run", "nightly", "rust-analyzer" },
}

require("lspconfig")["gopls"].setup {
    on_attach = on_attach,
    capabilities = capabilities,

    cmd = { "gopls", "serve" },
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
            buildFlags = { "-tags=integration" },
        },
    },
}
