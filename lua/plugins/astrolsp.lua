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
    local wgsl_indent_group = vim.api.nvim_create_augroup("wgsl_indent_on_save", { clear = true })

    opts.servers = opts.servers or {}
    table.insert(opts.servers, "slangd")
    table.insert(opts.servers, "roslyn_ls")

    -- vim.api.nvim_create_autocmd("LspAttach", {
    --   callback = function(args)
    --     local client = vim.lsp.get_client_by_id(args.data.client_id)
    --     if client and client.name == "roslyn" then client.server_capabilities.diagnosticProvider = nil end
    --   end,
    -- })
    vim.treesitter.language.register("wgsl_bevy", "wgsl")
    vim.treesitter.language.register("ldtk", "json")

    vim.api.nvim_create_autocmd("FileType", {
      group = wgsl_indent_group,
      pattern = { "wgsl", "wgsl_bevy" },
      callback = function(args) vim.b[args.buf].autoformat = false end,
    })

    vim.api.nvim_create_autocmd("BufWritePre", {
      group = wgsl_indent_group,
      callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if ft ~= "wgsl" and ft ~= "wgsl_bevy" then return end
        if not vim.bo[args.buf].modifiable or vim.bo[args.buf].buftype ~= "" then return end

        local view = vim.fn.winsaveview()
        vim.cmd "silent keepjumps normal! gg=G"
        vim.fn.winrestview(view)
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
        filetypes = { "slang", "shaderslang", "hlsl", "glsl" },
      },
      ["clang_format"] = {
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
      },
      ["roslyn_ls"] = {
        before_init = function(params, config)
          local root = config.root_dir
          if not root then return end

          local folder = {
            uri = vim.uri_from_fname(root),
            name = root,
          }

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
    opts.formatting = {
      disabled = {
        "lua_ls",
      },
    }
  end,
}
