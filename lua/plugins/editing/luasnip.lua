return {
  "L3MON4D3/LuaSnip",
  config = function(plugin, opts)
    require "astronvim.plugins.configs.luasnip"(plugin, opts)
    -- load snippets paths
    require("luasnip.loaders.from_lua").lazy_load {
      paths = { vim.fn.stdpath "config" .. "/snippets/luasnips" },
    }
  end,
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          i = {
            ["<C-E>"] = function()
              local ls = require "luasnip"
              if ls.choice_active() then ls.change_choice(1) end
            end,
          },
        },
      },
    },
  },
}
