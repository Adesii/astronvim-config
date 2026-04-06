-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing
---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = {
        virtual_lines = true,
        virtual_text = true,
      },
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
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
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      x = {
        ["<leader>P"] = [["_dP]],
      },

      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        ["<leader>jr"] = {
          function() require("user.type_renames").rename_params() end,
          desc = "Rename parameters to more sensible names",
        },
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
        -- ["<leader>,"] = { group = "No Neck Pain" },
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
        -- ["<leader>e"] = {
        --   function() require("snacks").explorer.open() end,
        --   desc = "Open Snacks File Picker",
        -- },
        -- File tree to yazi keybinds
        ["<leader>o"] = { "<Cmd>Yazi cwd<CR>", desc = "Resume Yazi" },
        -- GH integration:
        ["<leader>gi"] = { function() require("snacks").picker.gh_issue() end, desc = "GitHub Issues (open)" },
        ["<leader>gI"] = {
          function() require("snacks").picker.gh_issue { state = "all" } end,
          desc = "GitHub Issues (all)",
        },
        ["<leader>gO"] = { function() require("snacks").picker.gh_pr() end, desc = "GitHub Pull Requests (open)" },
        ["<leader>gP"] = {
          function() require("snacks").picker.gh_pr { state = "all" } end,
          desc = "GitHub Pull Requests (all)",
        },
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
      -- diagnostic_only_virtlines = {
      --   {
      --     event = { "CursorMoved", "DiagnosticChanged" },
      --     callback = function()
      --       if not require("astrocore.buffer").is_valid() then return end
      --       if og_virt_line == nil then og_virt_line = vim.diagnostic.config().virtual_lines end
      --
      --       -- ignore if virtual_lines.current_line is disabled
      --       if not (og_virt_line and og_virt_line.current_line) then
      --         if og_virt_text then
      --           vim.diagnostic.config { virtual_text = og_virt_text }
      --           og_virt_text = nil
      --         end
      --         return
      --       end
      --
      --       if og_virt_text == nil then og_virt_text = vim.diagnostic.config().virtual_text end
      --
      --       local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
      --
      --       if vim.tbl_isempty(vim.diagnostic.get(0, { lnum = lnum })) then
      --         vim.diagnostic.config { virtual_text = og_virt_text }
      --       else
      --         vim.diagnostic.config { virtual_text = false }
      --       end
      --     end,
      --   },
      --   {
      --     event = "ModeChanged",
      --     callback = function()
      --       if require("astrocore.buffer").is_valid() then pcall(vim.diagnostic.show) end
      --     end,
      --   },
      -- },
    },
  },
}
