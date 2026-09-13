---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    opts = function(_, opts)
      opts.servers = require("astrocore").list_insert_unique(opts.servers, { "slangd" })
      opts.config = require("astrocore").extend_tbl(opts.config or {}, {
        slangd = { cmd = { "slangd" }, filetypes = { "slang", "shaderslang", "hlsl", "glsl" } },
      })
      vim.treesitter.language.register("wgsl_bevy", "wgsl")
      vim.treesitter.language.register("ldtk", "json")
      local group = vim.api.nvim_create_augroup("wgsl_indent_on_save", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "wgsl", "wgsl_bevy" },
        callback = function(args) vim.b[args.buf].autoformat = false end,
      })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          if ft ~= "wgsl" and ft ~= "wgsl_bevy" then return end
          if not vim.bo[args.buf].modifiable or vim.bo[args.buf].buftype ~= "" then return end
          local view = vim.fn.winsaveview()
          vim.cmd "silent keepjumps normal! gg=G"
          vim.fn.winrestview(view)
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "wgsl", "wgsl_bevy" })
      end
    end,
  },
}
