local function toggle_omp()
  require("snacks").terminal.toggle("omp", {
    win = {
      position = "right",
      width = 0.4,
    },
  })
end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = {
    mappings = {
      n = {
        ["<leader>ao"] = { require("user.ai_toggle").guard(toggle_omp), desc = "Open OMP Terminal" },
      },
    },
  },
}
