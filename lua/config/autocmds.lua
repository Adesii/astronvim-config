if vim.g.vscode then return end

local inline_completion = vim.api.nvim_create_augroup("UserInlineCompletion", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = inline_completion,
  callback = function(args)
    local bufnr = args.buf
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, bufnr) then
      vim.lsp.inline_completion.enable(true, { bufnr = bufnr })
    end
  end,
})
