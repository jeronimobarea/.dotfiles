require("dapui").setup()

local dapui = require("dapui")
local dap = require("dap")
local nmap = require("jero.keymap").nmap

nmap("<space>dp", dapui.toggle)
nmap("<space>dt", dap.toggle_breakpoint)
nmap("<space>dn", dap.continue)
nmap("<space>do", dap.repl.open)
