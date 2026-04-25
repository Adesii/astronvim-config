if true then return {} end -- disable for now

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
      -- contexts = {
      --   -- Add the VectorCode context provider
      --   vectorcode = require("vectorcode.integrations.copilotchat").make_context_provider {
      --     prompt_header = "Here are relevant files from the repository:", -- Customize header text
      --     prompt_footer = "\nConsider this context when answering:", -- Customize footer text
      --     skip_empty = true, -- Skip adding context when no files are retrieved
      --   },
      -- },
      --
      -- -- Enable VectorCode context in your prompts
      -- prompts = {
      --   ExplainVec = {
      --     prompt = "Write an explanation for the selected code as paragraphs of text.",
      --     context = { "selection", "vectorcode" }, -- Add vectorcode to the context
      --   },
      --   FixVec = {
      --     prompt = "There is a problem in this code. Identify the issues and rewrite the code with fixes. Explain what was wrong and how your changes address the problems.",
      --     context = { "selection", "vectorcode" }, -- Add vectorcode to the context
      --   },
      --   OptimizeVec = {
      --     prompt = "Optimize the selected code to improve performance and readability. Explain your optimization strategy and the benefits of your changes.",
      --     context = { "selection", "vectorcode" }, -- Add vectorcode to the context
      --   },
      --   DocsVec = {
      --     prompt = "Please add documentation comments to the selected code.",
      --     context = { "selection", "vectorcode" }, -- Add vectorcode to the context
      --   },
      --   -- Other prompts...
      -- },
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
