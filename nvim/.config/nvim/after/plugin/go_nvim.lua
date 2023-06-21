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
    lsp_cfg = false,          -- true: apply go.nvim non-default gopls setup

    dap_debug = true,         -- set to false to disable dap
    dap_debug_keymap = false, -- true: use keymap for debugger defined in go/dap.lua
    -- false: do not use keymap in go/dap.lua.  you must define your own.
    -- windows: use visual studio keymap
    dap_debug_gui = true, -- bool|table put your dap-ui setup here set to false to disable
    dap_debug_vt = true,  -- bool|table put your dap-virtual-text setup here set to false to disable
}
