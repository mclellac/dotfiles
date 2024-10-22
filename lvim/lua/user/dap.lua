-- ~/.config/lvim/lua/user/dap.lua
local dap = require('dap-python')
dap.setup('~/.virtualenvs/debugpy/bin/python')

-- Optional custom configurations
dap.configurations.python = {
    {
        type = 'python',
        request = 'launch',
        name = "Launch file",
        program = "${file}",
        console = "integratedTerminal",
        justMyCode = false,  -- Enable debugging for full code
    },
}
