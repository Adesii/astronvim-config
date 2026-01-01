return {
  {
    "huggingface/llm.nvim",
    opts = {
      accept_keymap = "<S-Tab>",
      dismiss_keymap = nil,
      backend = "openai",
      url = "http://127.0.0.1:1234",
      model = "qwen2.5.1-coder-7b-instruct",

      fim = {
        enabled = true,
        prefix = "<|fim_prefix|>",
        middle = "<|fim_middle|>",
        suffix = "<|fim_suffix|>",
      },
      tokens_to_clear = { "<|cursor|>" },
      lsp = {
        bin_path = vim.api.nvim_call_function("stdpath", { "data" }) .. "/mason/bin/llm-ls",
      },
    },
    specs = {
      {
        "AstroNvim/astrocore",
        opts = {
          options = {
            g = {
              ai_accept = function()
                if require("llm.completion").shown_suggestion then
                  vim.schedule(require("llm.completion").complete)
                  return true
                end
              end,
            },
          },
        },
      },
    },
  },
  -- This is the configuration for the Minuet AI plugin. we commented out because it's not necessary for the current setup.
  -- {
  --   "milanglacier/minuet-ai.nvim",
  --   opts = function(plugin, opts)
  --     opts.virtualtext = {
  --       auto_trigger_ft = { "*" },
  --       keymap = {
  --         accept = nil,
  --       },
  --     }
  --     opts.blink = {
  --       enable_auto_complete = true,
  --     }
  --     opts.context_ratio = 0.5
  --     opts.request_timeout = 10
  --     opts.provider = "openai_fim_compatible"
  --     opts.n_completions = 1
  --     opts.context_window = 512
  --     opts.add_single_line_entry = true
  --     opts.provider_options = {
  --       openai_fim_compatible = {
  --         api_key = "TERM",
  --         name = "Ollama",
  --         end_point = "http://127.0.0.1:1234/v1/completions",
  --         model = "qwen2.5-coder-3b-instruct",
  --         optional = {
  --           max_tokens = 256,
  --         },
  --         template = {
  --           prompt = function(context_before_cursor, context_after_cursor, _)
  --             return "<|fim_prefix|>"
  --               .. context_before_cursor
  --               .. "<|fim_suffix|>"
  --               .. context_after_cursor
  --               .. "<|fim_middle|>"
  --           end,
  --           suffix = false,
  --         },
  --       },
  --     }
  --   end,
  -- },
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
