if true then return {} end -- disable for now
return {
  "Davidyz/VectorCode",
  event = "VeryLazy",
  version = "*", -- optional, depending on whether you're on nightly or release
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    on_setup = {
      update = false,
      lsp = true,
    },
    notify = false,
    async_backend = "lsp",
  },
}
