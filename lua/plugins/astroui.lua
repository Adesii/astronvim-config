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
    "rebelot/heirline.nvim",
    opts = function(_, opts)
      local status = require "astroui.status"
      local mineut_usage = require "minuet.heirline"

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
        {
          provider = function()
            local mstatus = mineut_usage:get_status()
            return mstatus.text
          end,
          hl = { fg = "fg", bg = "bg" },
          highlight = "Normal",
        },
        status.component.lsp(),
        status.component.virtual_env(),
        status.component.treesitter(),
        status.component.nav(),
        status.component.mode { surround = { separator = "right" } },
      }

      opts.winbar = { -- winbar
        init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
        fallthrough = false,
        { -- inactive winbar
          condition = function() return not status.condition.is_active() end,
          status.component.separated_path(),
          status.component.file_info {
            file_icon = {
              hl = status.hl.file_icon "winbar",
              padding = { left = 0 },
            },
            filename = {},
            filetype = false,
            file_read_only = false,
            hl = status.hl.get_attributes("winbarnc", true),
            surround = false,
            update = "BufEnter",
          },
        },
        { -- active winbar
          status.component.breadcrumbs {
            hl = status.hl.get_attributes("winbar", true),
          },
        },
      }

      opts.tabline = { -- tabline
        { -- file tree padding
          condition = function(self)
            self.winid = vim.api.nvim_tabpage_list_wins(0)[1]
            self.winwidth = vim.api.nvim_win_get_width(self.winid)
            return self.winwidth ~= vim.o.columns -- only apply to sidebars
              and not require("astrocore.buffer").is_valid(vim.api.nvim_win_get_buf(self.winid)) -- if buffer is not in tabline
          end,
          provider = function(self) return (" "):rep(self.winwidth + 1) end,
          hl = { bg = "tabline_bg" },
        },
        status.heirline.make_buflist(status.component.tabline_file_info()), -- component for each buffer tab
        status.component.fill { hl = { bg = "tabline_bg" } }, -- fill the rest of the tabline with background color
        { -- tab list
          condition = function() return #vim.api.nvim_list_tabpages() >= 2 end, -- only show tabs if there are more than one
          status.heirline.make_tablist { -- component for each tab
            provider = status.provider.tabnr(),
            hl = function(self) return status.hl.get_attributes(status.heirline.tab_type(self, "tab"), true) end,
          },
          { -- close button for current tab
            provider = status.provider.close_button {
              kind = "TabClose",
              padding = { left = 1, right = 1 },
            },
            hl = status.hl.get_attributes("tab_close", true),
            on_click = {
              callback = function() require("astrocore.buffer").close_tab() end,
              name = "heirline_tabline_close_tab_callback",
            },
          },
        },
      }

      opts.statuscolumn = { -- statuscolumn
        init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
        status.component.foldcolumn(),
        status.component.numbercolumn(),
        status.component.signcolumn(),
      }
    end,
  },
  {
    "catppuccin/nvim",
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
