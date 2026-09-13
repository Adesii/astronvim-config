return {
  x = {
    ["<leader>P"] = [["_dP]],
  },
  n = {
    -- Buffer navigation
    ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
    ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
    ["<Leader>bd"] = {
      function()
        require("astroui.status.heirline").buffer_picker(function(bufnr) require("astrocore.buffer").close(bufnr) end)
      end,
      desc = "Close buffer from tabline",
    },

    -- Editing and LSP
    ["<leader>jr"] = {
      function() require("user.type_renames").rename_params() end,
      desc = "Rename parameters to more sensible names",
    },
    J = "mzJ`z",
    ["<C-d>"] = "<C-d>zz",
    ["<C-u>"] = "<C-u>zz",
    n = "nzzzv",
    N = "Nzzzv",
    ["<leader>lz"] = "<cmd>LspRestart<cr>",
    ["<leader>D"] = { '"_d', desc = "Delete to void" },
    Q = "<nop>",
    ["<leader>s"] = { [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], desc = "Replace Hovered" },
    ["<leader>gG"] = { function() require("config.gist").file() end, desc = "Create private gist from file" },
  },
  v = {
    ["ö"] = { "[", remap = true },
    ["ä"] = { "]", remap = true },
    J = ":m '>+1<CR>gv=gv",
    K = ":m '<-2<CR>gv=gv",
    ["<leader>D"] = { '"_d', desc = "Delete to void" },
    ["<leader>gG"] = {
      function() require("config.gist").selection() end,
      desc = "Create private gist from selection",
    },
    ["<leader>y"] = [["+y]],
  },
  i = {
    ["<C-S-F12>"] = "<Esc>",
  },
}
