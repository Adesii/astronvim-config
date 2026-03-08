return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require "dap"
    dap.configurations.java = {
      {
        type = "java",
        request = "attach",
        name = "Attach HytaleServer",
        hostName = "localhost",
        port = 5005,
      },
    }
    dap.configurations.odin = {
      {
        type = "codelldb",
        request = "launch",
        name = "Launch file",
        program = function()
          vim.fn.system "odin build ./src/ -debug -o:none"
          return vim.fn.getcwd() .. "/" .. "src.bin"
        end,
        terminal = "integrated",
        cwd = "${workspaceFolder}",
      },
    }
  end,
}
