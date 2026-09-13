---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts.ensure_installed = { "lua-language-server", "stylua" }
      if require("config.plugins").enabled "tools.dap" then
        opts.ensure_installed[#opts.ensure_installed + 1] = "debugpy"
      end
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
    },
  },
}
