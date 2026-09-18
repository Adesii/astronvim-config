---@type LazySpec
return {
  {
    "Saghen/blink.cmp",
    opts = function(_, opts)
      if not opts.keymap then opts.keymap = {} end
      opts.completion.keyword = {
        range = "full",
      }
      opts.completion = {
        documentation = { auto_show = true },
        list = {
          selection = {
            preselect = true,
            auto_insert = false,
          },
        },
      }
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion", "txt", "help" },
  },
}
