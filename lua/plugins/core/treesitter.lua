-- Extra parsers belong to their language module.
---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = { ensure_installed = { "lua", "vim" }, indent = { enabled = true } },
}
