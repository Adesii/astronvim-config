-- Local Minuet experiment; imported only when ai.cmp_ai is enabled.
return {
  dir = vim.fn.stdpath "config" .. "/extpluginforks/minuet-ai.nvim",
  opts = function(_, opts)
    -- Roughly equate to 2000 tokens for LLM.
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
        suffix = false,
      },
    }
    opts.provider = "openai_fim_compatible"
    opts.n_completions = 2
    opts.context_window = 8000
    opts.request_timeout = 20
    opts.virtualtext = {
      auto_trigger_ft = { "*" },
    }
    opts.provider_options = {
      openai_fim_compatible = qwen3,
      openai_compatible = gemma4,
    }
  end,
  dependencies = { "nvim-lua/plenary.nvim" },
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        options = {
          g = {
            ai_accept = function()
              if require("minuet.virtualtext").action.is_visible() then
                vim.schedule(require("minuet.virtualtext").action.accept_line)
                return true
              end
            end,
          },
        },
        -- Alternative insert-mode suggestion navigation:
        -- mappings = {
        --   i = {
        --     ["<C-j>"] = {
        --       function() require("minuet.virtualtext").action.next() end,
        --     },
        --     ["<C-k>"] = {
        --       function() require("minuet.virtualtext").action.prev() end,
        --     },
        --   },
        -- },
      },
    },
    { "hrsh7th/nvim-cmp", optional = true },
    { "Saghen/blink.cmp", optional = true },
  },
}
