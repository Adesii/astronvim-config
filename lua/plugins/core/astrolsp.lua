-- Language-specific servers live in plugins/languages/.
---@type LazySpec
return {
  "AstroNvim/astrolsp",
  opts = {
    formatting = { disabled = { "lua_ls" } },
    config = {
      ["llm-ls"] = { capabilities = { offsetEncoding = "utf-16" } },
      clang_format = { filetypes = { "c", "cpp", "objc", "objcpp", "cuda" } },
    },
  },
}
