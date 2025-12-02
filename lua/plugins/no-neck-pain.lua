return {
  {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
    opts = {
      width = 150,
      mappings = {
        enabled = true,
        debug = false,
        toggle = "<leader>,p",
        toggleLeftSide = "<leader>,ql",
        toggleRightSide = "<leader>,qr",
        widthUp = false,
        widthDown = false,
        scratchPad = "<leader>,s",
      },
      autocmds = {
        enableOnVimEnter = true,
      },
      integrations = {
        NeoTree = {
          position = "left",
        },
        undotree = {
          position = "left",
        },
        dashboard = {
          enabled = true,
        },
      },
    },
    -- {
    --   "rebelot/heirline.nvim",
    --   opts = function(_, opts)
    --     local status = require "astroui.status"
    --     opts.winbar = { -- winbar
    --       init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
    --       fallthrough = false,
    --       { -- inactive winbar
    --         condition = function() return not status.condition.is_active() end,
    --       },
    --       { -- active winbar
    --         status.component.breadcrumbs {
    --           hl = status.hl.get_attributes("winbar", true),
    --         },
    --       },
    --     }
    --   end,
    -- },
  },
}
