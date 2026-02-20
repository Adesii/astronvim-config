return {
  -- {
  --   "huggingface/llm.nvim",
  --   opts = {
  --     accept_keymap = "<S-Tab>",
  --     dismiss_keymap = nil,
  --     backend = "openai",
  --     url = "http://127.0.0.1:1234/v1",
  --     model = "qwen2.5.1-coder-7b-instruct@q6_k_l",
  --
  --     fim = {
  --       enabled = true,
  --       prefix = "<|fim_prefix|>",
  --       middle = "<|fim_middle|>",
  --       suffix = "<|fim_suffix|>",
  --       -- Fim template kwaiCoder:
  --       -- prefix = "<|fim_begin|>",
  --       -- middle = "<|fim_hole|>",
  --       -- suffix = "<|fim_end|>",
  --     },
  --     tokens_to_clear = { "<|cursor|>" },
  --     lsp = {
  --       bin_path = vim.api.nvim_call_function("stdpath", { "data" }) .. "/mason/bin/llm-ls",
  --     },
  --   },
  --   specs = {
  --     {
  --       "AstroNvim/astrocore",
  --       opts = {
  --         options = {
  --           g = {
  --             ai_accept = function()
  --               if require("llm.completion").shown_suggestion then
  --                 vim.schedule(require("llm.completion").complete)
  --                 return true
  --               end
  --             end,
  --           },
  --         },
  --       },
  --     },
  --   },
  -- },
  -- This is the configuration for the Minuet AI plugin. we commented out because it's not necessary for the current setup.
  -- {
  --   "Davidyz/VectorCode",
  --   version = "0.7.20",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --   },
  -- },
  {
    "milanglacier/minuet-ai.nvim",
    opts = function(plugin, opts)
      opts.provider = "openai_fim_compatible"
      opts.n_completions = 1
      opts.context_window = 4096
      opts.virtualtext = {
        auto_trigger_ft = { "*" },
      }
      -- require("vectorcode").setup {
      --   -- number of retrieved documents
      --   n_query = 1,
      -- }
      --
      -- local has_vc, vectorcode_config = pcall(require, "vectorcode.config")
      -- local vectorcode_cacher = nil
      -- if has_vc then vectorcode_cacher = vectorcode_config.get_cacher_backend() end
      --
      -- -- roughly equate to 2000 tokens for LLM
      -- local RAG_Context_Window_Size = 8000
      --
      -- opts.provider_options = {
      --   openai_fim_compatible = { -- or codestral
      --     api_key = "TERM",
      --     name = "Ollama",
      --     end_point = "http://127.0.0.1:1234/v1/completions",
      --     model = "qwen2.5.1-coder-7b-instruct@q6_k_l",
      --     -- stream = true,
      --     optional = {
      --       max_tokens = 256,
      --       top_p = 0.9,
      --       stop = { "\n\n", "\n" },
      --     },
      --
      --     template = {
      --       prompt = function(pref, suff, _)
      --         local prompt_message = ""
      --         if has_vc then
      --           for _, file in ipairs(vectorcode_cacher.query_from_cache(0, { notify = false })) do
      --             prompt_message = prompt_message .. "<|file_sep|>" .. file.path .. "\n" .. file.document
      --           end
      --         end
      --
      --         prompt_message = vim.fn.strcharpart(prompt_message, 0, RAG_Context_Window_Size)
      --
      --         return prompt_message .. "<|fim_prefix|>" .. pref .. "<|fim_suffix|>" .. suff .. "<|fim_middle|>"
      --       end,
      --       suffix = false,
      --     },
      --   },
      --   dependencies = {
      --     "Davidyz/VectorCode",
      --   },
      -- }
      opts.provider_options = {
        openai_fim_compatible = {
          api_key = "TERM",
          name = "Ollama",
          end_point = "http://127.0.0.1:1234/v1/completions",
          model = "qwen2.5.1-coder-7b-instruct@q6_k_l",
          stream = true,
          optional = {
            max_tokens = 256,
            top_p = 0.9,
            stop = { "\n\n", "\n" },
          },
          -- template = {
          --   prompt = function(context_before_cursor, context_after_cursor, _)
          --     return "<|fim_prefix|>"
          --       .. context_before_cursor
          --       .. "<|fim_suffix|>"
          --       .. context_after_cursor
          --       .. "<|fim_middle|>"
          --   end,
          --   suffix = false,
          -- },
        },
      }
    end,

    specs = {
      {
        "AstroNvim/astrocore",
        opts = {
          options = {
            g = {
              ai_accept = function()
                if require("minuet.virtualtext").action.is_visible() then
                  vim.schedule(require("minuet.virtualtext").action.accept)
                  return true
                end
              end,
            },
          },
        },
      },
    },
  },
  {
    "Saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      opts.completion.keyword = {
        range = "full",
      }
      opts.list = { selection = { preselect = true } }
      opts.completion = { documentation = { auto_show = true } }
    end,
  },
}
