local function create_private_gist(text)
  local file_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
  if file_name == "" then file_name = "snippet.txt" end

  vim.system(
    { "gh", "gist", "create", "-", "--filename", file_name },
    {
      text = true,
      stdin = text,
    },
    vim.schedule_wrap(function(result)
      if result.code ~= 0 then
        local message = vim.trim(result.stderr ~= "" and result.stderr or "Failed to create gist")
        vim.notify(message, vim.log.levels.ERROR, { title = "GitHub Gist" })
        return
      end

      local url = vim.trim(result.stdout)
      if url ~= "" then vim.fn.setreg("+", url) end
      vim.notify("Private gist created: " .. url, vim.log.levels.INFO, { title = "GitHub Gist" })
    end)
  )
end

return {
  file = function()
    local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    create_private_gist(text)
  end,
  selection = function()
    local register = vim.fn.getreginfo "z"
    local selection = vim.o.selection
    vim.o.selection = "inclusive"
    vim.cmd [[silent normal! "zy]]
    vim.o.selection = selection

    local text = vim.fn.getreg "z"
    vim.fn.setreg("z", register)

    if text == "" then
      vim.notify("No visual selection to gist", vim.log.levels.WARN, { title = "GitHub Gist" })
      return
    end

    create_private_gist(text)
  end,
}
