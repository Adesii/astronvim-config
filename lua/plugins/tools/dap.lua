return {
  {
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
        {
          type = "codelldb",
          request = "attach",
          name = "Launch file",
          program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
        },
      }

      -- Attach to a running process with codelldb
      dap.configurations.cs = {
        {
          type = "codelldb",
          request = "attach",
          name = "Attach to process",
          pid = require("dap.utils").pick_process,
        },
      }
      dap.configurations.codelldb = {
        {
          type = "codelldb",
          request = "launch",
          name = "Launch file",
          program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
          terminal = "integrated",
          cwd = "${workspaceFolder}",
        },
      }
    end,
  },
}
