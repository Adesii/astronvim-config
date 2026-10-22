-- Language-specific servers live in plugins/languages/.
---@type LazySpec
return {
  "AstroNvim/astrolsp",
  opts = {
    formatting = { disabled = { "lua_ls" } },
    -- Copilot only starts while AI is enabled (<Leader>ad).
    handlers = { copilot = function(server) require("user.ai_toggle").lsp_handler(server) end },
    config = {
      ["llm-ls"] = { capabilities = { offsetEncoding = "utf-16" } },
      clang_format = { filetypes = { "c", "cpp", "objc", "objcpp", "cuda" } },
    },
  },
}
