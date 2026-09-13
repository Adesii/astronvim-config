---@type LazySpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      -- filtered_items = {
      --   hide_by_pattern = { "*.uid" },
      -- },
      group_empty_dirs = true,
      scan_mode = "deep",
    },
    group_empty_dirs = true,
    scan_mode = "deep",
  },
}
