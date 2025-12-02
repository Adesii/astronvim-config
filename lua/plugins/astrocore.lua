-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    options = {
      opt = {
        tabstop = 4,
        scrolloff = 8,
        shiftwidth = 4,
        softtabstop = 4,
        expandtab = true,
        ---FileManagement---
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
      },
      n = {
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
      },
      v = {
        J = ":m '>+1<CR>gv=gv",
        K = ":m '<-2<CR>gv=gv",

        ["<leader>D"] = { '"_d', desc = "Delete to void" },
        ["<leader>y"] = [["+y]],
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
