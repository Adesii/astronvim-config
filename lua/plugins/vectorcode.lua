-- if true then return {} end -- disable for now
return {
  "Davidyz/VectorCode",
  version = "*", -- optional, depending on whether you're on nightly or release
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function(_, opts)
    vim.lsp.config("vectorcode_server", {
      cmd = {
        "vectorcode-server",
      },
    })
    vim.lsp.enable("vectorcode_server", true)
  end,
  opts = {
    on_setup = {
      lsp = true,
    },
    notify = true,
    n_query = 10,
    timeout_ms = -1,
    async_backend = "lsp",
    async_opts = {
      events = { "BufWritePost" },
      single_job = true,
      query_cb = require("vectorcode.utils").make_surrounding_lines_cb(40),
      debounce = -1,
      n_query = 30,
    },
  },
}
