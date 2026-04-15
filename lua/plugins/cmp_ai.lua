-- if true then
--   return {
--     "Saghen/blink.cmp",
--     optional = true,
--     opts = function(_, opts)
--       opts.completion.keyword = {
--         range = "full",
--       }
--       opts.list = { selection = { preselect = true } }
--       opts.completion = { documentation = { auto_show = true } }
--     end,
--   }
-- end

return {
  {
    dir = vim.fn.stdpath "config" .. "/extpluginforks/minuet-ai.nvim",
    opts = function(plugin, opts)
      opts.provider = "openai_fim_compatible"
      opts.n_completions = 2
      opts.context_window = 4096
      opts.max_tokens = 64
      opts.virtualtext = {
        auto_trigger_ft = { "*" },
      }
      local has_vc, vectorcode_config = pcall(require, "vectorcode.config")
      local vectorcode_cacher = nil
      if has_vc then vectorcode_cacher = vectorcode_config.get_cacher_backend() end

      -- roughly equate to 2000 tokens for LLM
      local RAG_Context_Window_Size = 8000
      opts.provider_options = {
        openai_fim_compatible = {
          model = require "user.ai_model",
          api_key = "TERM",
          name = "Ollama",
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
              local prompt_message = ""
              if has_vc then
                for _, file in ipairs(vectorcode_cacher.query_from_cache(0)) do
                  prompt_message = prompt_message .. "<|file_sep|>" .. file.path .. "\n" .. file.document
                end
                vim.notify(prompt_message)
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
              end_point = "http://127.0.0.1:8080/v1/completions",
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
      { "Davidyz/VectorCode" },
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
        -- "snippet_forward",
        function()
          if vim.g.ai_accept then return vim.g.ai_accept() end
        end,
        "fallback",
      }
      opts.keymap["<S-Tab>"] = { "snippet_backward", "fallback" }
    end,
    {
      "Davidyz/VectorCode",
      version = "*", -- optional, depending on whether you're on nightly or release
      dependencies = { "nvim-lua/plenary.nvim" },
    },
  },
}
