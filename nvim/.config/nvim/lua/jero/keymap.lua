local M = {}

M.nmap = function(keymap, fun, opt)
    vim.keymap.set("n", keymap, fun, opt)
end

M.tmap = function(keymap, fun, opt)
    vim.keymap.set("t", keymap, fun, opt)
end

return M
