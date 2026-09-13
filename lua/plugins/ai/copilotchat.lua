local prefix = "<Leader>a"
return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    config = function(_, opts) require("CopilotChat").setup(opts) end,
    opts = {
      model = "gpt-5.4-mini", -- AI model to use
      temperature = 0.3, -- Lower = focused, higher = creative
      -- trusted_tools = nil, -- Require approval for all tool calls
      window = {
        layout = "vertical", -- 'vertical', 'horizontal', 'float'
        width = 0.4, -- 40% of screen width
      },
      eaders = {
        user = "👤 You",
        assistant = "🤖 Copilot",
        tool = "🔧 Tool",
      },
      separator = "━━",
      auto_fold = true, -- Automatically folds non-assistant messages
      auto_insert_mode = true, -- Enter insert mode when opening
    },
    specs = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          if not opts.mappings then opts.mappings = {} end
          opts.mappings.n = opts.mappings.n or {}
          opts.mappings.v = opts.mappings.v or {}
          opts.mappings.n[prefix] = { desc = require("astroui").get_icon("CodeCompanion", 1, true) .. "CodeCompanion" }
          opts.mappings.v[prefix] = { desc = require("astroui").get_icon("CodeCompanion", 1, true) .. "CodeCompanion" }
          opts.mappings.n[prefix .. "c"] = { "<cmd>CopilotChatToggle<cr>", desc = "Toggle chat" }
          opts.mappings.v[prefix .. "c"] = { "<cmd>CopilotChatToggle<cr>", desc = "Toggle chat" }
          opts.mappings.n[prefix .. "p"] = { "<cmd>CopilotChatPrompts<cr>", desc = "Open Prompts" }
          opts.mappings.v[prefix .. "p"] = { "<cmd>CopilotChatPrompts<cr>", desc = "Open Prompts" }
        end,
      },
    },
  },
}
