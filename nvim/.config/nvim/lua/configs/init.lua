function CreateNoremapGlobal(type, opts)
    return function (lhs, rhs)
        vim.api.nvim_set_keymap(type, lhs, rhs, opts)
    end
end

function CreateNoremap(type, opts)
    return function(lhs, rhs, bufnr)
        bufnr = bufnr or 0
        vim.api.nvim_buf_set_keymap(bufnr, type, lhs, rhs, opts)
    end
end

NnoremapGlobal = CreateNoremapGlobal("n", { noremap = true })
Nnoremap = CreateNoremap("n", { noremap = true })

require("configs.treesitter")
require("configs.airline")
require("configs.telescope")
require("configs.lsp")

