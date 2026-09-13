---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      -- change colorscheme
      colorscheme = require("config.plugins").enabled "ui.catppuccin" and "catppuccin-mocha" or "astrotheme",
    },
  },
  {
    "rebelot/heirline.nvim",
    opts = function(_, opts)
      local status = require "astroui.status"

      opts.statusline = { -- statusline
        hl = { fg = "fg", bg = "bg" },
        status.component.mode(),
        status.component.git_branch(),
        status.component.file_info(),
        status.component.git_diff(),
        status.component.diagnostics(),
        status.component.fill(),
        status.component.cmd_info(),
        status.component.fill(),
        status.component.lsp(),
        status.component.virtual_env(),
        status.component.treesitter(),
        status.component.nav(),
        status.component.mode {
          surround = { separator = "right" },
        },
      }
    end,
  },
  {
    "catppuccin/nvim",
    optional = true,
    opts = {
      auto_integrations = true,
      term_colors = true,
      compile_path = vim.fn.stdpath "cache" .. "/catppuccin",
      custom_highlights = function(colors)
        return {
          --------------------------------------------------------------------
          -- BASIC COLORS FROM ALT MOCHA
          --------------------------------------------------------------------
          Comment = { fg = "#6c7086", style = { "italic" } },
          String = { fg = "#a6e3a1" },
          Constant = { fg = "#eba0ac" },
          Keyword = { fg = "#cba6f7", style = { "bold" } },
          ["@punctuation"] = { fg = "#9399b2" },

          --------------------------------------------------------------------
          -- FUNCTIONS
          --------------------------------------------------------------------
          ["@function"] = { fg = "#89b4fa" },
          ["@function.call"] = { fg = "#89b4fa" },
          ["@function.builtin"] = { fg = "#74c7ec" },
          ["@function.decorator"] = { fg = "#94e2d5" },

          --------------------------------------------------------------------
          -- PARAMETERS
          --------------------------------------------------------------------
          ["@parameter"] = { fg = "#f2cdcd" },
          ["@lsp.type.parameter"] = { fg = "#f5e0dc" },

          -- “self”, “this”
          ["@variable.builtin"] = { fg = "#fab387", style = { "italic" } },

          --------------------------------------------------------------------
          -- TYPES (unified across TS + LSP)
          --------------------------------------------------------------------
          ["@type"] = { fg = "#b4befe" }, -- generic type
          ["@type.builtin"] = { fg = "#89dceb" },
          ["@type.definition"] = { fg = "#fab387" },

          --------------------------------------------------------------------
          -- CLASSES, STRUCTS, INTERFACES, ENUMS (C# / TS / Java / C++ / etc.)
          --------------------------------------------------------------------
          -- Tree-sitter
          ["@type.class"] = { fg = "#89dceb" },
          ["@type.struct"] = { fg = "#89dceb" },
          ["@type.enum"] = { fg = "#89dceb" },
          ["@type.interface"] = { fg = "#89dceb" },
          ["@type.namespace"] = { fg = "#89dceb" },
          ["@constructor"] = { fg = "#fab387" },

          -- LSP semantic tokens
          ["@lsp.type.class"] = { fg = "#89dceb" },
          ["@lsp.type.struct"] = { fg = "#a67bc5" },
          ["@lsp.type.enum"] = { fg = "#89dceb" },
          ["@lsp.type.interface"] = { fg = "#89dceb" },
          ["@lsp.type.namespace"] = { fg = "#a67bc5" },
          ["@lsp.type.typeParameter"] = { fg = "#b4befe" },

          -- class declaration identifiers
          ["@lsp.typemod.class.declaration"] = { fg = "#fab387" },
          ["@lsp.typemod.struct.declaration"] = { fg = "#fab387" },
          ["@lsp.typemod.enum.declaration"] = { fg = "#fab387" },

          --------------------------------------------------------------------
          -- FIELD / PROPERTY COLORS
          --------------------------------------------------------------------
          ["@variable.member"] = { fg = "#cdd6f4" },
          ["@lsp.type.property"] = { fg = "#cdd6f4" },

          --------------------------------------------------------------------
          -- C# SPECIFIC: so it matches VSCode EXACTLY
          --------------------------------------------------------------------
          ["@type.cs"] = { fg = "#89dceb" }, -- class names
          ["@type.builtin.cs"] = { fg = "#89dceb" }, -- int, float, etc
          ["@constructor.cs"] = { fg = "#fab387" },
          ["@keyword.cs"] = { fg = "#cba6f7", style = { "bold" } },
          ["@variable.member.cs"] = { fg = "#cdd6f4" },
        }
      end,
    },
  },
}
