-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  -- { import = "astrocommunity.pack.godot" },
  { import = "astrocommunity.pack.cs" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.cpp" },
  { import = "astrocommunity.recipes.ai" },
  -- { import = "astrocommunity.completion.minuet-ai-nvim" },
  { import = "astrocommunity.recipes.vscode" },
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.editing-support.undotree" },
  { import = "astrocommunity.motion.harpoon" },
  { import = "astrocommunity.completion.blink-cmp-tmux" },
  { import = "astrocommunity.pack.cmake" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.zig" },
  -- import/override with your plugins folder
}
