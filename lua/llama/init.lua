local M = {}

local job_id = nil

-- ring buffer
local logs = {}
local max_logs = 500

local function add_log(line)
  table.insert(logs, line)
  if #logs > max_logs then table.remove(logs, 1) end
end

local function notify(msg, level)
  if level == vim.log.levels.WARN or level == vim.log.levels.ERROR then
    vim.notify(msg, level, { title = "llama_runner" })
  end
end

local function is_error_line(line)
  line = line:lower()
  return line:match "error"
    or line:match "failed"
    or line:match "couldn't"
    or line:match "cannot"
    or line:match "fatal"
    or line:match "exiting"
end

local function is_warning_line(line)
  line = line:lower()
  return line:match "warn" or line:match "deprecated"
end

function M.start()
  if job_id then return end

  job_id = vim.fn.jobstart({ "llama" }, {
    detach = false,

    on_stdout = function(_, data, _)
      if not data then return end

      for _, line in ipairs(data) do
        if line ~= "" then
          add_log(line)

          if is_error_line(line) then
            notify(line, vim.log.levels.ERROR)
          elseif is_warning_line(line) then
            notify(line, vim.log.levels.WARN)
          end
        end
      end
    end,

    on_exit = function(_, code, _)
      if code ~= 0 then notify("llama exited with code " .. code, vim.log.levels.ERROR) end
      job_id = nil
    end,
  })
  notify("llama is starting...", vim.log.levels.INFO)

  if job_id <= 0 then
    notify("Failed to start llama job", vim.log.levels.ERROR)
    job_id = nil
  end
end

function M.stop()
  if job_id then
    local ok = vim.fn.jobstop(job_id)
    if ok == 0 then notify("Failed to stop llama job", vim.log.levels.WARN) end
    job_id = nil
  end
end

-- Command to view logs
function M.show_logs()
  vim.cmd "new" -- or "vnew" if you prefer vertical
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.filetype = "log"

  vim.api.nvim_buf_set_lines(0, 0, -1, false, logs)
end

function M.setup()
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function() M.start() end,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function() M.stop() end,
  })

  vim.api.nvim_create_user_command("LlamaLogs", function() M.show_logs() end, {})
end

return M
