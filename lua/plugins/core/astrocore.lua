---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 },
      autopairs = true,
      cmp = true,
      diagnostics = true,
      highlighturl = true,
      notifications = true,
    },
    diagnostics = {
      virtual_lines = {
        current_line = true,
      },
      virtual_text = {
        current_line = false,
      },
      update_in_insert = true,
    },
    options = require "config.options",
    mappings = require "config.mappings",
  },
}
