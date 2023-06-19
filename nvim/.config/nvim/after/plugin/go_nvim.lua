local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function()
        require("go.format").goimport()
    end,
    group = format_sync_grp,
})

if not pcall(require, "go") then
    return
end

require("go").setup {
    lsp_cfg = false, -- true: apply go.nvim non-default gopls setup
}
