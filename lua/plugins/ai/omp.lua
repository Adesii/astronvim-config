return {
  "rauls-kjarners/omp.nvim",
  commit = "aaf98b8b5f2c2cb0214321fa9b86575a7927dcc9",
  config = function()
    if require("user.ai_toggle").is_enabled() then require("omp").setup() end
  end,
}
