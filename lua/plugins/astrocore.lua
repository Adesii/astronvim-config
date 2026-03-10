-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options,
-- autocommands, and more! Configuration documentation can be found with `:h
-- astrocore` NOTE: We highly recommend setting up the Lua Language Server
-- (`:LspInstall lua_ls`) as this provides autocomplete and documentation while
-- editing
local og_virt_text
local og_virt_line
---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    features = {
      diagnostics = {
        virtual_lines = true,
        virtual_text = true,
      },
    },
    diagnostics = {
      virtual_text = true,
      virtual_lines = { current_line = true },
      update_in_insert = false,
      underline = true,
    },
    options = {
      opt = {
        scrolloff = 8,
        swapfile = false,
        backup = false,
        undodir = os.getenv "HOME" .. "/.cache/nvim/undodir",
        undofile = true,
        ---Search---
        hlsearch = false,
        incsearch = true,
      },
    },
    mappings = {
      x = {
        ["<leader>P"] = [["_dP]],
        ["ö"] = { "[", remap = true },
        ["ä"] = { "]", remap = true },
      },
      n = {
        ["<leader>jr"] = {
          function() require("user.type_renames").rename_params() end,
          desc = "Rename parameters to more sensible names",
        },
        ["ö"] = { "[", remap = true },
        ["ä"] = { "]", remap = true },
        J = "mzJ`z",
        ["<C-d>"] = "<C-d>zz",
        ["<C-u>"] = "<C-u>zz",
        n = "nzzzv",
        N = "Nzzzv",
        -- ["=ap"] = "ma=ap'a",
        ["<leader>lz"] = "<cmd>LspRestart<cr>",
        ["<leader>D"] = { '"_d', desc = "Delete to void" },
        Q = "<nop>",
        ["<leader>s"] = { [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], desc = "Replace Hovered" },
        ["<leader>,"] = { group = "No Neck Pain" },
        ["<leader>f;"] = {
          function()
            -- This uses grep to find words in files but excluding txt,binaries,log etc... that couldn't be part of the code.
            require("snacks").picker.grep {
              ignored = true,
              follow = true,
              ft = { "java", "gdscript", "lua", "csharp", "python", "rust", "go" },
            }
          end,
          desc = "Find in Programming Language",
        },
        ["<leader>f,"] = {
          function()
            -- This uses grep to find words in the current file
            require("snacks").picker.grep {
              need_search = false,
              dirs = { vim.api.nvim_buf_get_name(0) },
              layout = {
                preset = "ivy",
              },
              format = function(item)
                local ret = { { string.format("%s: ", item.pos[1]), "Conceal" } }
                require("snacks").picker.highlight.format(item, item.line, ret)
                return ret
              end,
            }
          end,
          desc = "Find in Current File",
        },
        --LSP Search Features
        ["grr"] = { function() require("snacks").picker.lsp_references() end, desc = "Search References" },
        ["grd"] = { function() require("snacks").picker.lsp_definitions() end, desc = "Go to Definition" },
        ["grw"] = {
          function() require("snacks").picker.lsp_workspace_symbols() end,
          desc = "Workspace Symbols",
        },
        ["grD"] = { function() require("snacks").picker.lsp_declarations() end, desc = "Search Declarations" },
        ["gri"] = {
          function() require("snacks").picker.lsp_implementations() end,
          desc = "Search Implementation",
        },
        ["<leader>e"] = {
          function() require("snacks").picker.files() end,
          desc = "Open Snacks File Picker",
        },
        -- File tree to yazi keybinds
        ["<leader>o"] = { "<Cmd>Yazi Resume<CR>", desc = "Resume Yazi" },
      },
      v = {
        ["ö"] = { "[", remap = true },
        ["ä"] = { "]", remap = true },
        J = ":m '>+1<CR>gv=gv",
        K = ":m '<-2<CR>gv=gv",

        ["<leader>D"] = { '"_d', desc = "Delete to void" },
        ["<leader>y"] = [["+y]],
      },
      i = {
        ["<C-E>"] = function()
          local ls = require "luasnip"
          if ls.choice_active() then ls.change_choice(1) end
        end,
      },
    },
    autocmds = {
      diagnostic_only_virtlines = {
        {
          event = { "CursorMoved", "DiagnosticChanged" },
          callback = function()
            if not require("astrocore.buffer").is_valid() then return end
            if og_virt_line == nil then og_virt_line = vim.diagnostic.config().virtual_lines end

            -- ignore if virtual_lines.current_line is disabled
            if not (og_virt_line and og_virt_line.current_line) then
              if og_virt_text then
                vim.diagnostic.config { virtual_text = og_virt_text }
                og_virt_text = nil
              end
              return
            end

            if og_virt_text == nil then og_virt_text = vim.diagnostic.config().virtual_text end

            local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1

            if vim.tbl_isempty(vim.diagnostic.get(0, { lnum = lnum })) then
              vim.diagnostic.config { virtual_text = og_virt_text }
            else
              vim.diagnostic.config { virtual_text = false }
            end
          end,
        },
        {
          event = "ModeChanged",
          callback = function()
            if require("astrocore.buffer").is_valid() then pcall(vim.diagnostic.show) end
          end,
        },
      },
    },
    -- options = {
    --   opts = {
    --     tabstop = 4,
    --   },
    -- },
    --
    -- mappings = {
    --   n = {
    --     -- ["<leader>pv"] = vim.cmd.Ex,
    --   },
    -- },
  },
}
