-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = function(plugin, opts)
    opts.servers = opts.servers or {}
    table.insert(opts.servers, "slangd")

    opts.config = require("astrocore").extend_tbl(opts.config or {}, {
      ["llm-ls"] = {
        capabilities = {
          offsetEncoding = "utf-16",
        },
      },
      slangd = {
        cmd = {
          "slangd",
        },
        filetypes = { "slang", "shaderslang" },
      },
    })
  end,
}
