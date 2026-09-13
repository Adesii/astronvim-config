local zeta_provider = {
  type = "zeta-2.1",
  model = "Zeta2.1",
  url = "http://127.0.0.1:8080",
  temperature = 0.0,

  context_size = 4096,
  max_tokens = 192,
  max_diff_history_tokens = 256,

  top_k = 50,
  completion_timeout = 4000,

  privacy_mode = true,
}

local sweep_provider = {
  type = "sweep",
  url = "http://localhost:8080",
  model = "Sweep",

  temperature = 0.0,
  context_size = 4096,
  max_tokens = 192,
  max_diff_history_tokens = 256,
  completion_timeout = 2000,

  privacy_mode = true,
}

return {
  "cursortab/cursortab.nvim",
  lazy = false,
  build = "cd server && go build",
  opts = {
    provider = zeta_provider,
    keymaps = {
      accept = "<Tab>",
      partial_accept = "<S-Tab>",
      trigger = false,
    },
    behavior = {
      idle_completion_delay = 120,
      text_change_debounce = 100,
      max_visible_lines = 8,

      enabled_modes = { "insert" },

      cursor_prediction = {
        enabled = true,
        auto_advance = true,
        proximity_threshold = 2,
      },
    },
  },
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = assert(opts.mappings)
        maps.n["<Leader>at"] = { "<Cmd>CursortabToggle<CR>", desc = "Toggle CursorTab" }
      end,
    },
  },
}
