return {
  "L3MON4D3/LuaSnip",
  config = function(plugin, opts)
    require "astronvim.plugins.configs.luasnip"(plugin, opts)
    -- load snippets paths
    require("luasnip.loaders.from_lua").lazy_load {
      paths = { "~/.config/nvim/snippets/luasnips/" },
    }
    require("luasnip.loaders.from_vscode").lazy_load {
      paths = { "~/.config/nvim/snippets/friendlysnippets/" },
    }
    opts.history = false
    opts.delete_check_events = "TextChanged"
  end,
}
