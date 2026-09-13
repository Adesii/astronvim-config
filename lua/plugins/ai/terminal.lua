---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = {
    mappings = {
      n = {
        ["<leader>ao"] = {
          function()
            require("snacks").terminal.toggle("omp", {
              win = {
                position = "right",
                width = 0.4,
              },
            })
          end,
          desc = "Open OMP Terminal",
        },
      },
    },
  },
}
