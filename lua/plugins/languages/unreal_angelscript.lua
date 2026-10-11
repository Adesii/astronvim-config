return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.filetype.add {
        extension = { as = "angelscript" },
      }

      vim.lsp.config("unreal_angelscript", {
        cmd = {
          "node",
          vim.fn.expand "~/.local/share/ue-angelscript-lsp/language-server/dist/server.js",
        },
        filetypes = { "angelscript" },
        root_dir = function(bufnr, on_dir)
          local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))

          while dir do
            if vim.fs.basename(dir) == "Script" then
              on_dir(dir)
              return
            end

            local parent = vim.fs.dirname(dir)
            if parent == dir then break end
            dir = parent
          end
        end,
      })

      vim.lsp.enable "unreal_angelscript"
    end,
  },
}
