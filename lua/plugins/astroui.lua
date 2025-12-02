--if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      -- change colorscheme
      colorscheme = "catppuccin-mocha",
      -- -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
      -- highlights = {
      --   init = { -- this table overrides highlights in all themes
      --     -- Normal = { bg = "#000000" },
      --   },
      --   astrodark = { -- a table of overrides/changes when applying the astrotheme theme
      --     -- Normal = { bg = "#000000" },
      --   },
      -- },
      -- -- Icons can be configured throughout the interface
      -- icons = {
      --   -- configure the loading of the lsp in the status line
      --   LSPLoading1 = "⠋",
      --   LSPLoading2 = "⠙",
      --   LSPLoading3 = "⠹",
      --   LSPLoading4 = "⠸",
      --   LSPLoading5 = "⠼",
      --   LSPLoading6 = "⠴",
      --   LSPLoading7 = "⠦",
      --   LSPLoading8 = "⠧",
      --   LSPLoading9 = "⠇",
      --   LSPLoading10 = "⠏",
      -- },
    },
  },
  {
    "catppuccin/nvim",
    opts = {
      auto_integrations = true,
      term_colors = true,
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
