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
    table.insert(opts.servers, "roslyn_ls")
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "roslyn_ls" then client.server_capabilities.diagnosticProvider = nil end
      end,
    })

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
      ["roslyn_ls"] = {
        cmd = {
          "roslyn-language-server",
          "--stdio",
          "--autoLoadProjects",
          "--logLevel",
          "Information",
          "--extensionLogDirectory",
          vim.fs.joinpath(vim.uv.os_tmpdir(), "roslyn_ls/logs"),
        },
        settings = {
          ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "openFiles",
            dotnet_compiler_diagnostics_scope = "openFiles",
          },
        },
      },
    })
    opts.formatting = {
      disabled = {
        "lua_ls",
      },
    }
  end,
}
