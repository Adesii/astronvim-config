return {
  "ThePrimeagen/99",
  opts = function(plugin, opts)
    local _99 = require "99"

    local cwd = vim.uv.cwd()
    local basename = vim.fs.basename(cwd)
    opts.model = "lmstudio_custom/unsloth/qwen3.5-9b"
    opts.provider = _99.Providers.OpenCodeProvider
    opts.logger = {
      level = _99.DEBUG,
      path = "/tmp/" .. basename .. ".99.debug",
      print_on_error = true,
    }
    -- When setting this to something that is not inside the CWD tools
    -- such as claude code or opencode will have permission issues
    -- and generation will fail refer to tool documentation to resolve
    -- https://opencode.ai/docs/permissions/#external-directories
    -- https://code.claude.com/docs/en/permissions#read-and-edit
    opts.tmp_dir = "./tmp"

    --- Completions: #rules and @files in the prompt buffer
    opts.completion = {
      custom_rules = {
        "scratch/custom_rules/",
      },

      --- Configure @file completion (all fields optional, sensible defaults)
      files = {},
      source = "blink", -- "native" (default), "cmp", or "blink"
    }

    vim.keymap.set("v", "<leader>9v", function() _99.visual() end)

    vim.keymap.set("n", "<leader>9x", function() _99.stop_all_requests() end)

    vim.keymap.set("n", "<leader>9s", function() _99.search() end)
    vim.keymap.set("n", "<leader>9l", function() _99.view_logs() end)
  end,
}
