return {
  {
    "shortcuts/no-neck-pain.nvim",
    opts = {
      width = 160,
      mappings = {
        enabled = true,
        debug = false,
        toggle = "<leader>,p",
        toggleLeftSide = "<leader>,l",
        toggleRightSide = "<leader>,r",
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
  },
}
