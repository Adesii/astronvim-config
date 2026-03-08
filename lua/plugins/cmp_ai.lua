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
    dir = "/mnt/8tbhdd/Projects/Programming/nvim/minuet-ai.nvim",
    opts = function(plugin, opts)
      opts.provider = "openai_fim_compatible"
      opts.n_completions = 1
      opts.context_window = 4096
      opts.virtualtext = {
        auto_trigger_ft = { "*" },
      }
      opts.provider_options = {
        openai_fim_compatible = {
          model = "unsloth/qwen3.5-9b",
          api_key = "TERM",
          name = "Ollama",
          end_point = "http://127.0.0.1:1234/v1/completions",
          stream = true,
          optional = {
            max_tokens = 128,
          },
        },
      }
      opts.presets = {
        mecury = {
          context_window = 256,
          throttle = 1500, -- Increase to reduce costs and avoid rate limits
          debounce = 600, -- Increase to reduce costs and avoid rate limits
          provider_options = {
            openai_fim_compatible = {
              model = "mercury-coder",
              end_point = "https://api.inceptionlabs.ai/v1/fim/completions",
              api_key = "INCEPTION_API_KEY", -- environment variable name
              stream = true,
              top_p = 1.0,
              stop = {},
            },
          },
        },
        qwen35 = {
          context_window = 4096,
          provider_options = {
            openai_fim_compatible = {
              model = "qwen3.5-9b",
              api_key = "TERM",
              name = "Ollama",
              end_point = "http://127.0.0.1:1234/v1/completions",
              stream = true,

              optional = {
                max_tokens = 128,
                top_p = 0.95,
                stop = {},
              },
            },
          },
        },
        qwen25 = {
          provider_options = {
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
            },
          },
        },
      }
    end,
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },

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
        },
      },
      { "hrsh7th/nvim-cmp", optional = true },
      { "Saghen/blink.cmp", optional = true },
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
