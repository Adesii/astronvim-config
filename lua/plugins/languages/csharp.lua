---@type LazySpec
return {
  "AstroNvim/astrolsp",
  opts = function(_, opts)
    opts.servers = require("astrocore").list_insert_unique(opts.servers, { "roslyn_ls" })
    opts.config = require("astrocore").extend_tbl(opts.config or {}, {
      roslyn_ls = {
        before_init = function(params, config)
          local root = config.root_dir
          if not root then return end
          local folder = { uri = vim.uri_from_fname(root), name = root }
          params.rootUri = folder.uri
          params.rootPath = root
          params.workspaceFolders = { folder }
        end,
        cmd = {
          "roslyn-language-server",
          "--logLevel",
          "Information",
          "--extensionLogDirectory",
          vim.fs.joinpath(vim.uv.os_tmpdir(), "roslyn_ls/logs"),
          "--autoLoadProjects",
          "--stdio",
        },
        settings = {
          ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "openFiles",
            dotnet_compiler_diagnostics_scope = "openFiles",
          },
        },
      },
    })
  end,
}
