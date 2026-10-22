-- Master switch for every AI feature (Copilot LSP, Sidekick, OMP, Minuet).
-- The state persists across restarts via a marker file, so a no-AI project
-- stays AI-free until toggled back on.
local M = {}

local state_file = vim.fn.stdpath "state" .. "/ai_disabled"
local enabled = not vim.uv.fs_stat(state_file)

-- LSP configs that are AI backends; only these are managed by the switch.
local lsp_servers = { "copilot" }

-- State captured when disabling, so enabling restores only what was running.
local restore = {}

function M.is_enabled() return enabled end

local function notify(msg, level) vim.notify(msg, level or vim.log.levels.INFO, { title = "AI" }) end

--- Wrap a mapping action so it is inert while AI is disabled.
---@param fn function
function M.guard(fn)
  return function(...)
    if enabled then return fn(...) end
    notify("AI is disabled (<Leader>ad to enable)", vim.log.levels.WARN)
  end
end

--- astrolsp handler: skip enabling AI language servers while disabled, which
--- keeps Copilot from ever receiving buffer contents when starting disabled.
---@param server string
function M.lsp_handler(server)
  if enabled then vim.lsp.enable(server) end
end

local features = {
  copilot = {
    off = function()
      for _, name in ipairs(lsp_servers) do
        vim.lsp.enable(name, false) -- also stops running clients
      end
    end,
    on = function()
      for _, name in ipairs(lsp_servers) do
        if vim.fn.executable "copilot-language-server" == 1 then vim.lsp.enable(name, true) end
      end
    end,
  },
  sidekick = {
    off = function()
      local nes = package.loaded["sidekick.nes"]
      restore.nes = nes and nes.enabled or false
      if nes then nes.disable() end
      if package.loaded["sidekick.cli"] then require("sidekick.cli").close { all = true } end
    end,
    on = function()
      local ok, nes = pcall(require, "sidekick.nes")
      if ok and restore.nes ~= false then nes.enable() end
    end,
  },
  omp = {
    -- Stops cursor/file tracking. Already-open OMP sockets are only closed on exit.
    off = function()
      pcall(vim.api.nvim_del_augroup_by_name, "OmpNvimGroup")
      local terminal = package.loaded["snacks"] and require("snacks").terminal
      if terminal then
        for _, term in ipairs(terminal.list()) do
          local cmd = term.cmd
          if cmd == "omp" or (type(cmd) == "table" and cmd[1] == "omp") then term:close() end
        end
      end
    end,
    on = function()
      local ok, omp = pcall(require, "omp")
      if ok and not pcall(vim.api.nvim_get_autocmds, { group = "OmpNvimGroup" }) then omp.setup() end
    end,
  },
  minuet = {
    off = function()
      restore.minuet = package.loaded["minuet"] ~= nil
      if restore.minuet then vim.cmd "silent! Minuet virtualtext disable" end
    end,
    on = function()
      if restore.minuet then vim.cmd "silent! Minuet virtualtext enable" end
    end,
  },
}

local function apply(on)
  for name, feature in pairs(features) do
    local ok, err = pcall(on and feature.on or feature.off)
    if not ok then
      notify(("Failed to %s %s: %s"):format(on and "enable" or "disable", name, err), vim.log.levels.ERROR)
    end
  end
end

local function persist(on)
  if on then
    os.remove(state_file)
  else
    vim.fn.mkdir(vim.fs.dirname(state_file), "p")
    local f = io.open(state_file, "w")
    if f then f:close() end
  end
end

---@param on boolean
function M.set(on)
  if on == enabled then return end
  enabled = on
  vim.g.ai_enabled = on
  pcall(persist, on)
  apply(on)
  notify(on and "AI features enabled" or "AI features disabled")
end

function M.toggle() M.set(not enabled) end

vim.g.ai_enabled = enabled

-- Starting disabled: plugin specs check is_enabled() (Sidekick NES, OMP) and the
-- astrolsp handler blocks Copilot, so nothing needs shutting down at startup.
return M
