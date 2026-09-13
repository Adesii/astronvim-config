-- Local instruction experiment; imported only when ai.llama is enabled.
return {
  {
    "ggml-org/llama.vim",
    init = function()
      vim.g.llama_config = {
        auto_fim = false,
        endpoint_inst = "http://127.0.0.1:8080/v1/chat/completions",
        model_inst = require "user.ai_model",
        keymap_fim_trigger = "",
        keymap_fim_accept_word = "",
        keymap_inst_trigger = "",
        keymap_inst_rerun = "",
        keymap_inst_continue = "",
        keymap_debug_toggle = "",
      }
    end,
  },
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        v = {
          ["i"] = { ":LlamaInstruct<CR>" },
        },
      },
    },
  },
  -- Alternative local implementation:
  -- {
  --   dir = vim.fn.stdpath "config" .. "/lua/llama",
  --   config = function() require("llama").setup() end,
  -- },
}
