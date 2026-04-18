-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE
local MinuetStatus = {
  static = {
    processing = false,
    spinner_index = 1,
    n_requests = 0,
    n_finished_requests = 0,
    display_name = "Ollama",
    spinner_symbols = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
    timer = nil,
  },

  init = function(self)
    if self.initialized then return end
    local group = vim.api.nvim_create_augroup("MinuetHeirline", { clear = true })

    local function toggle_timer(start)
      if start and not self.timer then
        self.timer = vim.uv.new_timer()
        self.timer:start(
          0,
          100,
          vim.schedule_wrap(function()
            self.spinner_index = (self.spinner_index % #self.spinner_symbols) + 1
            -- vim.cmd "redrawstatus"
          end)
        )
      elseif not start and self.timer then
        self.timer:stop()
        self.timer:close()
        self.timer = nil
      end
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "MinuetRequestStartedPre",
      group = group,
      callback = function(args)
        local data = args.data
        self.n_requests = data.n_requests
        self.n_finished_requests = 0
        self.display_name = data.model or data.name or "Ollama"
        -- vim.cmd "redrawstatus"
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MinuetRequestStarted",
      group = group,
      callback = function()
        self.processing = true
        toggle_timer(true)
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MinuetRequestFinished",
      group = group,
      callback = function()
        self.n_finished_requests = self.n_finished_requests + 1
        if self.n_finished_requests >= self.n_requests then
          self.processing = false
          toggle_timer(false)
        end
        -- vim.cmd "redrawstatus"
      end,
    })
    self.initialized = true
  end,

  -- We now also listen to InsertLeave to hide it when you stop typing
  update = {
    "User",
    pattern = { "MinuetRequestStartedPre", "MinuetRequestStarted", "MinuetRequestFinished" },
    "InsertLeave",
    "InsertEnter",
  },
  condition = function() return vim.api.nvim_get_mode().mode == "i" end,
  provider = function(self)
    local counter = (self.n_requests > 1) and string.format(" (%s/%s)", self.n_finished_requests, self.n_requests) or ""
    local icon = self.processing and (" " .. self.spinner_symbols[self.spinner_index]) or " "

    return " " .. self.display_name .. counter .. icon
  end,
  -- CHANGE COLOR HERE
  hl = { fg = "white", bold = true },
}

local SidekickStatus = {
  condition = function() return require("sidekick.status").get() ~= nil end,

  provider = function() return " " end,

  hl = function()
    local status = require("sidekick.status").get()
    if not status then return end

    if status.kind == "Error" then
      return "DiagnosticError"
    elseif status.busy then
      return "DiagnosticWarn"
    else
      return { fg = "white", bold = true }
    end
  end,
}
local SidekickCLI = {
  condition = function() return #require("sidekick.status").cli() > 0 end,

  provider = function()
    local status = require("sidekick.status").cli()
    return " " .. (#status > 1 and #status or "")
  end,

  hl = { fg = "white", bold = true },
}
local vectorcode_component = {
  provider = function()
    return require("vectorcode.integrations")
      .heirline({
        show_job_count = true,
        component_opts = {},
      })
      .provider()
  end,
  condition = function()
    if package.loaded["vectorcode"] == nil then
      return true
    else
      return require("vectorcode.integrations").heirline().condition()
    end
  end,
}
-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      -- change colorscheme
      colorscheme = "catppuccin-mocha",
    },
  },
  {
    "rebelot/heirline.nvim",
    opts = function(_, opts)
      local status = require "astroui.status"
      -- local mineut_usage = require "minuet.heirline"

      opts.statusline = { -- statusline
        hl = { fg = "fg", bg = "bg" },
        status.component.mode(),
        status.component.git_branch(),
        status.component.file_info(),
        status.component.git_diff(),
        status.component.diagnostics(),
        SidekickStatus,
        SidekickCLI,
        -- vectorcode_component,
        -- MinuetStatus,

        status.component.fill(),
        status.component.cmd_info(),
        status.component.fill(),
        -- {
        --   provider = function()
        --     local mstatus = mineut_usage:get_status()
        --     return mstatus.text
        --   end,
        --   hl = { fg = "fg", bg = "bg" },
        --   highlight = "Normal",
        -- },
        status.component.lsp(),
        status.component.virtual_env(),
        status.component.treesitter(),
        status.component.nav(),
        status.component.mode {
          surround = { separator = "right" },
        },
      }
    end,
  },
  {
    "catppuccin/nvim",
    opts = {
      auto_integrations = true,
      term_colors = true,
      compile_path = vim.fn.stdpath "cache" .. "/catppuccin",
      custom_highlights = function(colors)
        return {
          --------------------------------------------------------------------
          -- BASIC COLORS FROM ALT MOCHA
          --------------------------------------------------------------------
          Comment = { fg = "#6c7086", style = { "italic" } },
          String = { fg = "#a6e3a1" },
          Constant = { fg = "#eba0ac" },
          Keyword = { fg = "#cba6f7", style = { "bold" } },
          ["@punctuation"] = { fg = "#9399b2" },

          --------------------------------------------------------------------
          -- FUNCTIONS
          --------------------------------------------------------------------
          ["@function"] = { fg = "#89b4fa" },
          ["@function.call"] = { fg = "#89b4fa" },
          ["@function.builtin"] = { fg = "#74c7ec" },
          ["@function.decorator"] = { fg = "#94e2d5" },

          --------------------------------------------------------------------
          -- PARAMETERS
          --------------------------------------------------------------------
          ["@parameter"] = { fg = "#f2cdcd" },
          ["@lsp.type.parameter"] = { fg = "#f5e0dc" },

          -- “self”, “this”
          ["@variable.builtin"] = { fg = "#fab387", style = { "italic" } },

          --------------------------------------------------------------------
          -- TYPES (unified across TS + LSP)
          --------------------------------------------------------------------
          ["@type"] = { fg = "#b4befe" }, -- generic type
          ["@type.builtin"] = { fg = "#89dceb" },
          ["@type.definition"] = { fg = "#fab387" },

          --------------------------------------------------------------------
          -- CLASSES, STRUCTS, INTERFACES, ENUMS (C# / TS / Java / C++ / etc.)
          --------------------------------------------------------------------
          -- Tree-sitter
          ["@type.class"] = { fg = "#89dceb" },
          ["@type.struct"] = { fg = "#89dceb" },
          ["@type.enum"] = { fg = "#89dceb" },
          ["@type.interface"] = { fg = "#89dceb" },
          ["@type.namespace"] = { fg = "#89dceb" },
          ["@constructor"] = { fg = "#fab387" },

          -- LSP semantic tokens
          ["@lsp.type.class"] = { fg = "#89dceb" },
          ["@lsp.type.struct"] = { fg = "#a67bc5" },
          ["@lsp.type.enum"] = { fg = "#89dceb" },
          ["@lsp.type.interface"] = { fg = "#89dceb" },
          ["@lsp.type.namespace"] = { fg = "#a67bc5" },
          ["@lsp.type.typeParameter"] = { fg = "#b4befe" },

          -- class declaration identifiers
          ["@lsp.typemod.class.declaration"] = { fg = "#fab387" },
          ["@lsp.typemod.struct.declaration"] = { fg = "#fab387" },
          ["@lsp.typemod.enum.declaration"] = { fg = "#fab387" },

          --------------------------------------------------------------------
          -- FIELD / PROPERTY COLORS
          --------------------------------------------------------------------
          ["@variable.member"] = { fg = "#cdd6f4" },
          ["@lsp.type.property"] = { fg = "#cdd6f4" },

          --------------------------------------------------------------------
          -- C# SPECIFIC: so it matches VSCode EXACTLY
          --------------------------------------------------------------------
          ["@type.cs"] = { fg = "#89dceb" }, -- class names
          ["@type.builtin.cs"] = { fg = "#89dceb" }, -- int, float, etc
          ["@constructor.cs"] = { fg = "#fab387" },
          ["@keyword.cs"] = { fg = "#cba6f7", style = { "bold" } },
          ["@variable.member.cs"] = { fg = "#cdd6f4" },
        }
      end,
    },
  },
}
