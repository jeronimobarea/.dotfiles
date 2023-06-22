require("dapui").setup()

local dapui = require("dapui")
local dap = require("dap")
local nmap = require("jero.keymap").nmap

nmap("<leader>dp", dapui.toggle)
nmap("<leader>dt", dap.toggle_breakpoint)
nmap("<leader>dn", dap.continue)
nmap("<leader>do", dap.repl.open)
