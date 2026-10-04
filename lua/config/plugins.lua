-- The only plugin-selection file. Restart Neovim after changing it.
-- Module names are relative to lua/plugins/; false skips the entire spec.
local groups = { core = true, ui = true, editing = true, tools = true, languages = true, ai = true }
local modules = {
  ["core.astrocore"] = true,
  ["core.astrolsp"] = true,
  ["core.treesitter"] = true,
  ["ui.astroui"] = true,
  ["ui.snacks"] = true,
  ["ui.neo-tree"] = false,
  ["ui.no-neck-pain"] = true,
  ["editing.completion"] = true,
  ["editing.luasnip"] = true,
  ["editing.mini"] = true,
  ["tools.mason"] = true,
  ["tools.none-ls"] = true,
  ["tools.dap"] = true,
  ["tools.super-productivity"] = true,
  ["languages.godot"] = true,
  ["languages.geckscript"] = true,
  ["languages.shaders"] = true,
  ["languages.csharp"] = true,
  ["languages.odin"] = true,
  ["languages.lua"] = true,
  ["languages.python"] = true,
  ["languages.rust"] = true,
  ["languages.cpp"] = true,
  ["languages.typescript"] = true,
  ["languages.html-css"] = true,
  ["ai.recipe"] = true,
  ["core.vscode"] = true,
  ["ui.catppuccin"] = true,
  ["editing.undotree"] = true,
  -- Alternative C# setups; enable only one C# implementation at a time.
  ["languages.csharp-ls"] = false,
  ["languages.roslyn-plugin"] = false,
  ["ai.cursortab"] = false,
  ["ai.minuet"] = false,
  ["ai.omp"] = true,
  ["ai.terminal"] = true,
  ["ai.99"] = false,
  ["ai.cmp_ai"] = false,
  ["ai.codecompanion"] = false,
  ["ai.copilotchat"] = false,
  ["ai.llama"] = false,
  ["ai.mcphub"] = false,
  ["ai.sidekick"] = true,
  ["ai.vectorcode"] = false,
}

-- Community packs load before local overrides. These switches use the same
-- groups and profile overrides as local modules.
local community = {
  { "languages.lua", "astrocommunity.pack.lua" },
  { "languages.python", "astrocommunity.pack.python", "python" },
  { "languages.rust", "astrocommunity.pack.rust", "rust" },
  { "languages.cpp", "astrocommunity.pack.cpp" },
  { "ai.recipe", "astrocommunity.recipes.ai" },
  { "core.vscode", "astrocommunity.recipes.vscode" },
  { "ui.catppuccin", "astrocommunity.colorscheme.catppuccin" },
  { "editing.undotree", "astrocommunity.editing-support.undotree" },
  { "languages.typescript", "astrocommunity.pack.typescript", "js,ts,typescript,javascript" },
  { "languages.html-css", "astrocommunity.pack.html-css" },
}

-- Hard exclusions for plugins supplied by AstroNvim, packs, or dependencies.
-- Remove an entry to allow that plugin again. Skipping a local customization
-- alone does not remove a plugin supplied by an upstream pack.
local disabled = {
  "nvim-neo-tree/neo-tree.nvim",
  "zbirenbaum/copilot.lua",
  "github/copilot.vim",
}

local profiles = {
  personal = {},
  work = {
    groups = { ai = false },
    modules = {
      ["tools.super-productivity"] = false,
      ["tools.dap"] = false,
      ["ui.no-neck-pain"] = false,
      ["languages.godot"] = false,
      ["languages.geckscript"] = false,
      ["languages.shaders"] = false,
      ["languages.csharp"] = false,
      ["languages.odin"] = false,
      ["languages.rust"] = false,
      ["languages.cpp"] = false,
      ["languages.typescript"] = false,
      ["languages.html-css"] = false,
    },
    disabled = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "jay-babu/mason-nvim-dap.nvim",
    },
  },
  school = {
    groups = { ai = false },
    modules = {
      ["tools.super-productivity"] = false,
      ["tools.dap"] = false,
      ["languages.godot"] = false,
      ["languages.geckscript"] = false,
      ["languages.shaders"] = false,
      ["languages.odin"] = false,
      ["languages.lua"] = false,
      ["languages.python"] = false,
      ["languages.rust"] = false,
      ["languages.cpp"] = false,
      ["languages.typescript"] = false,
      ["languages.html-css"] = false,
    },
    disabled = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "jay-babu/mason-nvim-dap.nvim",
    },
  },
}

local M = { profile = vim.env.NVIM_PROFILE or "personal" }
local profile = assert(profiles[M.profile], "Unknown NVIM_PROFILE: " .. M.profile)
for name, value in pairs(profile.groups or {}) do
  groups[name] = value
end
for name, value in pairs(profile.modules or {}) do
  modules[name] = value
end

function M.enabled(name) return groups[name:match "^[^.]+"] == true and modules[name] == true end

function M.community()
  ---@type LazySpec
  local specs = { "AstroNvim/astrocommunity" }
  for _, entry in ipairs(community) do
    if M.enabled(entry[1]) then specs[#specs + 1] = { import = entry[2], ft = entry[3] } end
  end
  return specs
end

function M.specs()
  local community_names = {}
  for _, entry in ipairs(community) do
    community_names[entry[1]] = true
  end
  local specs = {}
  for name in pairs(modules) do
    if not community_names[name] and M.enabled(name) then specs[#specs + 1] = { import = "plugins." .. name } end
  end
  -- Base UI precedes integrations that extend its statusline; language specs
  -- extend shared tools. Within a group, imports are alphabetical.
  local order = { core = 1, ui = 2, editing = 3, tools = 4, languages = 5, ai = 6 }
  table.sort(specs, function(a, b)
    local a_group = order[a.import:match "^plugins%.([^.]+)"]
    local b_group = order[b.import:match "^plugins%.([^.]+)"]
    if a_group == b_group then return a.import < b.import end
    return a_group < b_group
  end)
  for _, repo in ipairs(disabled) do
    specs[#specs + 1] = { repo, enabled = false }
  end
  for _, repo in ipairs(profile.disabled or {}) do
    specs[#specs + 1] = { repo, enabled = false }
  end
  return specs
end

return M
