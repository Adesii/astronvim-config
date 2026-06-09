if vim.g.vscode then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here
--
-- vim.api.nvim_create_autocmd("InsertLeave", {
--   callback = function()
--     if
--       require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
--       and not require("luasnip").session.jump_active
--     then
--       require("luasnip").unlink_current()
--     end
--   end,
-- })
-- vim.lsp.enable("roslyn_ls", true)

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, bufnr) then
      vim.lsp.inline_completion.enable(true, { bufnr = bufnr })
      -- vim.notify "inline completion supported"
      -- Set up keymaps for accepting and switching inline completions
      -- vim.keymap.set(
      --   "i",
      --   "<C-j>",
      --   vim.lsp.inline_completion.select,
      --   { desc = "LSP: switch inline completion", buffer = bufnr }
      -- )
    end
  end,
})

-- vim.lsp.enable("copilot", true)

-- vim.lsp.inline_completion.enable()
-- vim.lsp.config("vectorcode-server", {
--   cmd = {
--     "vectorcode-server",
--   },
-- })
--
-- vim.lsp.enable("vectorcode-server", true)
-- local luasnip = require "luasnip"
-- vim.api.nvim_create_autocmd("InsertLeave", {
--   callback = function()
--     if luasnip.session.current_nodes[vim.api.nvim_get_current_buf()] then luasnip.unlink_current() end
--   end,
-- })

-- VectorCode Register
-- vim.api.nvim_create_autocmd("LspAttach", {
--   callback = function()
--     -- Check if vectorcode config module is available
--     local has_vc, vectorcode_config = pcall(require, "vectorcode.config")
--     local vectorcode_cacher = nil
--     if has_vc then vectorcode_cacher = vectorcode_config.get_cacher_backend() end
--
--     -- Get the current buffer number
--     local bufnr = vim.api.nvim_get_current_buf()
--     -- Async check for config and register the buffer with vectorcode
--     require("vectorcode.cacher").utils.async_check("config", function()
--       if vectorcode_cacher then vectorcode_cacher.register_buffer(bufnr, {
--         n_query = 5,
--       }) end
--     end, nil)
--   end,
--   desc = "Register buffer for VectorCode",
-- })
--
-- vim.api.nvim_create_autocmd("LspDetach", {
--   callback = function(args)
--     -- Check if vectorcode config module is available
--     local has_vc, vectorcode_config = pcall(require, "vectorcode.config")
--     local vectorcode_cacher = nil
--     if has_vc then vectorcode_cacher = vectorcode_config.get_cacher_backend() end
--
--     -- Check if buffer is registered and deregister it
--     if vectorcode_cacher and vectorcode_cacher.buf_is_registered(vim.api.nvim_get_current_buf()) then
--       if vectorcode_cacher then vectorcode_cacher.deregister_buffer(args.buf) end
--     end
--   end,
--   desc = "Unregister buffer for VectorCode",
-- })
