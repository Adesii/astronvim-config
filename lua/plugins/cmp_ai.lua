local function accept_completion_per_word(item, mode)
  local insert_text = item.insert_text
  if type(insert_text) == "string" then
    local range = item.range
    if range then
      vim.notify(
        vim.inspect(vim.tbl_keys(range)) .. "Range Keys.  " .. vim.inspect(vim.tbl_values(range)) .. "Range Values"
      )
      local lines = vim.split(insert_text, "\n")
      local bufnr = vim.api.nvim_get_current_buf()
      local start_row = range[1]
      local start_col = range[2]
      local end_row = range[3]
      local end_col = range[4]

      local current_lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})

      local row = 1
      while row <= #lines and row <= #current_lines and lines[row] == current_lines[row] do
        row = row + 1
      end

      local col = 1
      while
        row <= #lines
        and col <= #lines[row]
        and row <= #current_lines
        and col <= #current_lines[row]
        and lines[row][col] == current_lines[row][col]
      do
        col = col + 1
      end

      local word = string.match(lines[row]:sub(col), "%s*[^%s]%w*")
      item.insert_text = table.concat(vim.list_slice(lines, 1, row - 1), "\n")
        .. (row <= #current_lines and "" or "\n")
        .. (row <= #lines and col <= #lines[row] and lines[row]:sub(1, col - 1) or "")
        .. word
    end
  end
  return item
end

local function accept_completion_per_line(item, mode)
  local insert_text = item.insert_text
  if type(insert_text) == "string" then
    local range = item.range
    if range then
      local lines = vim.split(insert_text, "\n")
      local bufnr = vim.api.nvim_get_current_buf()
      local start_row = range[1]
      local start_col = range[2]
      local end_row = range[3]
      local end_col = range[4]

      local current_lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})

      -- Find the first line that differs
      local row = 1
      while row <= #lines and row <= #current_lines and lines[row] == current_lines[row] do
        row = row + 1
      end

      -- Accept all lines up to the first differing line
      item.insert_text = table.concat(vim.list_slice(lines, 1, row), "\n")
    end
  end
  return item
end
-- -- roughly equate to 2000 tokens for LLM
local RAG_Context_Window_Size = 2000
local gemma4 = {
  model = require "user.ai_model",
  end_point = "http://127.0.0.1:8080/v1/chat/completions",
  api_key = "TERM",
  name = "llama",
  stream = true,
  optional = {
    reasoning_effort = "minimal",
    reasoning_budget = 0,
  },
  system = {
    template = "{{{prompt}}}\n{{{guidelines}}}\n{{{n_completion_template}}}\n{{{repo_context}}}",
    repo_context = [[9. Additional context from other files in the repository will be enclosed in <repo_context> tags. Each file will be separated by <file_separator> tags, containing its relative path and content.]],
  },
  chat_input = {
    template = "{{{repo_context}}}\n{{{language}}}\n{{{tab}}}\n<contextBeforeCursor>\n{{{context_before_cursor}}}<cursorPosition>\n<contextAfterCursor>\n{{{context_after_cursor}}}",
    repo_context = function(_, _, _)
      local prompt_message = ""
      local has_vc, vectorcode_config = pcall(require, "vectorcode.config")
      local vectorcode_cacher = nil
      if has_vc then vectorcode_cacher = vectorcode_config.get_cacher_backend() end
      if has_vc then
        local cache_result = vectorcode_cacher.query_from_cache(0)
        for _, file in ipairs(cache_result) do
          prompt_message = prompt_message .. "<file_separator>" .. file.path .. "\n" .. file.document
        end
      end
      prompt_message = vim.fn.strcharpart(prompt_message, 0, RAG_Context_Window_Size)

      if prompt_message ~= "" then prompt_message = "<repo_context>\n" .. prompt_message .. "\n</repo_context>" end
      return prompt_message
    end,
  },
}
local qwen3 = {
  model = require "user.ai_model",
  api_key = "TERM",
  name = "llama",
  end_point = "http://127.0.0.1:8080/v1/completions",
  stream = true,
  optional = {
    max_tokens = 56,
    top_p = 0.9,
  },
  -- Llama.cpp does not support the `suffix` option in FIM completion.
  -- Therefore, we must disable it and manually populate the special
  -- tokens required for FIM completion.
  template = {
    prompt = function(pref, suff, _)
      local has_vc, vectorcode_config = pcall(require, "vectorcode.config")
      local vectorcode_cacher = nil
      if has_vc then vectorcode_cacher = vectorcode_config.get_cacher_backend() end

      local prompt_message = ""
      if has_vc and vectorcode_cacher and vectorcode_cacher.buf_is_registered(vim.api.nvim_get_current_buf()) then
        for _, file in ipairs(vectorcode_cacher.query_from_cache(0)) do
          prompt_message = prompt_message .. "<|file_sep|>" .. file.path .. "\n" .. file.document
        end
      end

      prompt_message = vim.fn.strcharpart(prompt_message, 0, RAG_Context_Window_Size)
      return prompt_message .. "<|fim_prefix|>" .. pref .. "<|fim_suffix|>" .. suff .. "<|fim_middle|>"
    end,
    -- prompt = function(context_before_cursor, context_after_cursor, _)
    --   return "<|fim_prefix|>"
    --     .. context_before_cursor
    --     .. "<|fim_suffix|>"
    --     .. context_after_cursor
    --     .. "<|fim_middle|>"
    -- end,
    suffix = false,
  },
}
return {
  -- {
  --   dir = vim.fn.stdpath "config" .. "/extpluginforks/minuet-ai.nvim",
  --   opts = function(plugin, opts)
  --     opts.provider = "openai_fim_compatible"
  --     opts.n_completions = 2
  --     opts.context_window = 8000
  --     opts.request_timeout = 20
  --
  --     opts.virtualtext = {
  --       auto_trigger_ft = { "*" },
  --     }
  --     opts.provider_options = {
  --       openai_fim_compatible = qwen3,
  --       openai_compatible = gemma4,
  --     }
  --   end,
  --   dependencies = {
  --     { "nvim-lua/plenary.nvim" },
  --     -- { "Davidyz/VectorCode" },
  --   },
  --
  --   specs = {
  --     {
  --       "AstroNvim/astrocore",
  --       opts = {
  --         options = {
  --           g = {
  --             ai_accept = function()
  --               if require("minuet.virtualtext").action.is_visible() then
  --                 vim.schedule(require("minuet.virtualtext").action.accept_line)
  --                 return true
  --               end
  --             end,
  --           },
  --         },
  --       },
  --     },
  --     { "hrsh7th/nvim-cmp", optional = true },
  --     { "Saghen/blink.cmp", optional = true },
  --   },
  -- },
  -- {
  --   "github/copilot.vim",
  --   -- opts = function(_, opts) vim.g.copilot_no_tab_map = true end,
  --   specs = {
  --     {
  --       "catppuccin",
  --       optional = true,
  --       ---@module 'catppuccin'
  --       ---@type CatppuccinOptions
  --       opts = { integrations = { copilot_vim = true } },
  --     },
  --   },
  -- },
  {
    "Saghen/blink.cmp",
    opts = function(_, opts)
      if not opts.keymap then opts.keymap = {} end
      opts.completion.keyword = {
        range = "full",
      }
      -- opts.list = { selection = { preselect = true } }
      opts.completion = {
        documentation = { auto_show = true },
        list = {
          selection = {
            -- show_and_insert = true,
            preselect = true,
            auto_insert = true,
          },
        },
      }
      opts.keymap["<Tab>"] = {
        "snippet_forward",
        function()
          local nes = require "sidekick.nes"
          if nes.have() and (nes.jump() or nes.apply()) then return true end
          if vim.lsp.inline_completion.get { on_accept = accept_completion_per_line } then return true end
        end,
        "fallback",
      }
      opts.keymap["<S-Tab>"] = { "snippet_backward", "fallback" }
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion", "txt", "help" },
  },
  -- {
  --   "Davidyz/VectorCode",
  --   event = "VeryLazy",
  --   version = "*", -- optional, depending on whether you're on nightly or release
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   opts = {
  --     on_setup = {
  --       update = false,
  --       lsp = true,
  --     },
  --     notify = true,
  --     async_backend = "lsp",
  --   },
  -- },
  -- {
  --   "olimorris/codecompanion.nvim",
  --   event = "VeryLazy",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --     "MeanderingProgrammer/render-markdown.nvim",
  --   },
  --   opts = {
  --     adapters = {
  --       http = {
  --         llamacpp = function()
  --           return require("codecompanion.adapters").extend("openai_compatible", {
  --             env = {
  --               url = "http://127.0.0.1:8080", -- replace with your llama.cpp instance
  --               api_key = "TERM",
  --               chat_url = "/v1/chat/completions",
  --               model = require "user.ai_model",
  --             },
  --           })
  --         end,
  --       },
  --     },
  --     interactions = {
  --       chat = {
  --         adapter = {
  --           name = "llamacpp",
  --           model = require "user.ai_model",
  --         },
  --       },
  --       inline = {
  --         adapter = {
  --           name = "llamacpp",
  --           model = require "user.ai_model",
  --         },
  --       },
  --       background = {
  --         adapter = {
  --           name = "llamacpp",
  --           model = require "user.ai_model",
  --         },
  --       },
  --     },
  --     -- extensions = {
  --     --   vectorcode = {
  --     --     ---@type VectorCode.CodeCompanion.ExtensionOpts
  --     --     opts = {
  --     --       tool_group = {
  --     --         -- this will register a tool group called `@vectorcode_toolbox` that contains all 3 tools
  --     --         enabled = true,
  --     --         -- a list of extra tools that you want to include in `@vectorcode_toolbox`.
  --     --         -- if you use @vectorcode_vectorise, it'll be very handy to include
  --     --         -- `file_search` here.
  --     --         extras = {},
  --     --         collapse = false, -- whether the individual tools should be shown in the chat
  --     --       },
  --     --       tool_opts = {
  --     --         ---@type VectorCode.CodeCompanion.ToolOpts
  --     --         ["*"] = {},
  --     --         ---@type VectorCode.CodeCompanion.LsToolOpts
  --     --         ls = {},
  --     --         ---@type VectorCode.CodeCompanion.VectoriseToolOpts
  --     --         vectorise = {},
  --     --         ---@type VectorCode.CodeCompanion.QueryToolOpts
  --     --         query = {
  --     --           max_num = { chunk = -1, document = -1 },
  --     --           default_num = { chunk = 50, document = 10 },
  --     --           include_stderr = false,
  --     --           use_lsp = false,
  --     --           no_duplicate = true,
  --     --           chunk_mode = false,
  --     --           ---@type VectorCode.CodeCompanion.SummariseOpts
  --     --           summarise = {
  --     --             ---@type boolean|(fun(chat: CodeCompanion.Chat, results: VectorCode.QueryResult[]):boolean)|nil
  --     --             enabled = false,
  --     --             adapter = nil,
  --     --             query_augmented = true,
  --     --           },
  --     --         },
  --     --         files_ls = {},
  --     --         files_rm = {},
  --     --       },
  --     --     },
  --     --   },
  --     -- },
  --   },
}
