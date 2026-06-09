if true then return {} end

vim.lsp.config("roslyn", {
  settings = {
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
    },
    ["csharp|code_lens"] = {
      dotnet_enable_references_code_lens = true,
    },
    ["csharp|background_analysis"] = {
      dotnet_analyzer_diagnostics_scope = "openFiles",
      dotnet_compiler_diagnostics_scope = "openFiles",
    },
    ["csharp|completion"] = {
      dotner_provide_regex_completion = true,
      dotnet_show_completion_item_from_unimported_namespaces = true,
      dotnet_show_name_completion_suggestions = true,
    },
  },
})
return {
  -- -@module 'roslyn.config'
  "seblyng/roslyn.nvim",
  -- -@type RoslynNvimConfig
  opts = {
    -- your configuration comes here; leave empty for default settings
    silent = true,
  },
}
