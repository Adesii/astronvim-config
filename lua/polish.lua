-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

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
local luasnip = require "luasnip"

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    if luasnip.session.current_nodes[vim.api.nvim_get_current_buf()] then luasnip.unlink_current() end
  end,
})
-- local has_vc, vectorcode_config = pcall(require, "vectorcode.config")
-- local vectorcode_cacher = nil
-- if has_vc then vectorcode_cacher = vectorcode_config.get_cacher_backend() end
-- vim.api.nvim_create_autocmd("LspAttach", {
--   callback = function()
--     local bufnr = vim.api.nvim_get_current_buf()
--     require("vectorcode.cacher").utils.async_check(
--       "config",
--       function()
--         vectorcode_cacher.register_buffer(bufnr, {
--           n_query = 10,
--         })
--       end,
--       nil
--     )
--   end,
--   desc = "Register buffer for VectorCode",
-- })
