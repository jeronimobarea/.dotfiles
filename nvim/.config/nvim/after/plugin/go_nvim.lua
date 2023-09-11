if not pcall(require, "go") then
    return
end

require("go").setup({
    lsp_cfg = false,          -- true: apply go.nvim non-default gopls setup

    dap_debug = true,         -- set to false to disable dap
    dap_debug_keymap = false, -- true: use keymap for debugger defined in go/dap.lua
    -- false: do not use keymap in go/dap.lua.  you must define your own.
    -- windows: use visual studio keymap
    dap_debug_gui = true, -- bool|table put your dap-ui setup here set to false to disable
})
