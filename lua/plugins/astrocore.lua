-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

local function create_private_gist(text)
  local file_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
  if file_name == "" then file_name = "snippet.txt" end

  vim.system(
    { "gh", "gist", "create", "-", "--filename", file_name },
    {
      text = true,
      stdin = text,
    },
    vim.schedule_wrap(function(result)
      if result.code ~= 0 then
        local message = vim.trim(result.stderr ~= "" and result.stderr or "Failed to create gist")
        vim.notify(message, vim.log.levels.ERROR, { title = "GitHub Gist" })
        return
      end

      local url = vim.trim(result.stdout)
      if url ~= "" then vim.fn.setreg("+", url) end
      vim.notify("Private gist created: " .. url, vim.log.levels.INFO, { title = "GitHub Gist" })
    end)
  )
end

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
      diagnostics = true,
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    diagnostics = {
      virtual_lines = {
        current_line = true,
      },
      virtual_text = {
        current_line = false,
      },
      update_in_insert = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = true, -- sets vim.opt.wrap
        scrolloff = 8,
        swapfile = false,
        backup = false,
        undodir = os.getenv "HOME" .. "/.cache/nvim/undodir",
        undofile = true,
        ---Search---
        hlsearch = false,
        incsearch = true,
        completeopt = "menu,menuone,noselect,popup",
        -- indent settings
        autoindent = true,
        smartindent = true,
        cindent = false,
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
        ["<leader>fdb"] = {
          -- Search inside bevy examples
          function()
            require("snacks").picker.grep {
              cwd = "/mnt/8tbhdd/Projects/Programming/Rust/bevy/examples",
              layout = {
                preset = "ivy",
              },
            }
          end,
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
          function()
            require("snacks").explorer.open()
            -- only refresh no neck pain if the snacks explorer is open, otherwise it will cause a flicker when opening the explorer
            local feedkeys = function(keys, mode)
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), mode, true)
            end
            --Refresh no neck pain after a few frames
            -- Do this for now by focusing the main buffer and then going back to the explorer after a few frames
            -- Emulate the <l> keypress to refresh the no neck pain plugin
            vim.defer_fn(function()
              if require("snacks").picker.get({ source = "explorer" })[1] then
                feedkeys("<C-w>p", "n")
                vim.defer_fn(function() feedkeys("<C-w>p", "n") end, 50)
              end
            end, 50)
          end,
          desc = "Open Snacks File Picker",
        },
        ["<leader>o"] = {
          function()
            -- if the snacks explorer is already open, focus it, otherwise open it
            local Snacks = require "snacks"
            local explorer = Snacks.picker.get({ source = "explorer" })[1]
            if explorer then
              explorer:focus "list"
            else
              Snacks.explorer.open()
            end
          end,
          desc = "Resume Snacks Picker",
        },
        -- File tree to yazi keybinds
        -- ["<leader>o"] = { "<Cmd>Yazi cwd<CR>", desc = "Resume Yazi" },
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
        ["<leader>gG"] = {
          function()
            local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
            create_private_gist(text)
          end,
          desc = "Create private gist from file",
        },
        ["<leader>ji"] = ":CodeCompanionChat<CR>",
        ["<leader>ja"] = ":CodeCompanionActions<CR>",
      },

      v = {
        ["ö"] = { "[", remap = true },
        ["ä"] = { "]", remap = true },
        J = ":m '>+1<CR>gv=gv",
        K = ":m '<-2<CR>gv=gv",

        ["<leader>D"] = { '"_d', desc = "Delete to void" },
        ["<leader>gG"] = {
          function()
            local register = vim.fn.getreginfo "z"
            local selection = vim.o.selection
            vim.o.selection = "inclusive"
            vim.cmd [[silent normal! "zy]]
            vim.o.selection = selection

            local text = vim.fn.getreg "z"
            vim.fn.setreg("z", register)

            if text == "" then
              vim.notify("No visual selection to gist", vim.log.levels.WARN, { title = "GitHub Gist" })
              return
            end

            create_private_gist(text)
          end,
          desc = "Create private gist from selection",
        },
        ["<leader>y"] = [["+y]],
        ["<leader>ai"] = ":CodeCompanion ",
        ["<leader>aa"] = ":CodeCompanionChat<CR>",
      },
      i = {
        -- ["<C-j>"] = {
        --   function() require("minuet.virtualtext").action.next() end,
        -- },
        -- ["<C-k>"] = {
        --   function() require("minuet.virtualtext").action.prev() end,
        -- },
        ["<C-E>"] = function()
          local ls = require "luasnip"
          if ls.choice_active() then ls.change_choice(1) end
        end,
        -- exit insert mode
        ["<C-S-F12>"] = "<Esc>",
        -- ["<Tab>"] = {
        --   function(fallback)
        --     local nes = require "sidekick.nes"
        --     if nes.have() and (nes.jump() or nes.apply()) then
        --       vim.notify("Applied snippet choice", vim.log.levels.INFO, { title = "AstroCore" })
        --       return true
        --     end
        --     if vim.lsp.inline_completion.get() then
        --       vim.notify("Accepted inline completion", vim.log.levels.INFO, { title = "AstroCore" })
        --       return true
        --     end
        --     vim.notify("No snippet choice or inline completion to accept", vim.log.levels.INFO, { title = "AstroCore" })
        --
        --   end,
        -- },
      },
    },
  },
}
