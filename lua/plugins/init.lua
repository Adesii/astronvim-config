-- Only selected modules are imported; disabled files are never evaluated.
---@type LazySpec
return require("config.plugins").specs()
