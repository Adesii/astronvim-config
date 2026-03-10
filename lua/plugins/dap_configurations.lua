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
      }
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    config = function(plugin, opts)
      -- run default AstroNvim nvim-dap-ui configuration function
      require "astronvim.plugins.configs.nvim-dap-ui"(plugin, opts)

      -- disable dap events that are created
      local dap = require "dap"
      dap.listeners.after.event_initialized.dapui_config = nil
      dap.listeners.before.event_terminated.dapui_config = nil
      dap.listeners.before.event_exited.dapui_config = nil
    end,
  },
}
