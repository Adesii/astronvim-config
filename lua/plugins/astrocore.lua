-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options,
-- autocommands, and more! Configuration documentation can be found with `:h
-- astrocore` NOTE: We highly recommend setting up the Lua Language Server
-- (`:LspInstall lua_ls`) as this provides autocomplete and documentation while
-- editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
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
              -- ignored = true,
              follow = true,
              ft = { "java", "gdscript", "lua", "csharp", "python", "odin", "rust", "go" },
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
