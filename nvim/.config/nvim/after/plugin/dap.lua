local dap = require("dap")
local dapui = require("dapui")
local nmap = require("jero.keymap").nmap

dapui.setup()

nmap("<leader>dp", dapui.toggle)
nmap("<leader>dt", dap.toggle_breakpoint)
nmap("<leader>dn", dap.continue)
nmap("<leader>do", dap.repl.open)
