local prefix = "<Leader>a"
return {
  "olimorris/codecompanion.nvim",
  event = "User AstroFile",
  -- version = "v18.7.0",
  version = "v19.13.0",
  cmd = {
    "CodeCompanion",
    "CodeCompanionActions",
    "CodeCompanionChat",
    "CodeCompanionCmd",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "MeanderingProgrammer/render-markdown.nvim",
    -- "ravitemer/mcphub.nvim",
  },
  opts = {
    interactions = {
      cli = {
        agent = "copilot",
        agents = {
          opencode = {
            cmd = "opencode",
            args = {},
            description = "OpenCode Cli",
            provider = "terminal",
          },
          copilot = {
            cmd = "copilot",
            args = {},
            description = "Copilot Cli",
            provider = "terminal",
          },
        },
      },
      chat = {
        adapter = {
          name = "opencode",
          model = "GitHub Copilot/GPT-5.4 Mini",
        },
      },
      inline = {
        adapter = {
          name = "opencode",
          model = "GitHub Copilot/GPT-5.4 Mini",
        },
        keymaps = {
          accept_change = {
            modes = { n = "ga" },
            description = "Accept change",
          },
          reject_change = {
            modes = { n = "gr" },
            description = "Reject change",
          },
        },
      },
    },
    extensions = {
      -- mcphub = {
      --   callback = "mcphub.extensions.codecompanion",
      --   opts = {
      --     -- MCP Tools
      --     make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
      --     show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
      --     add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
      --     show_result_in_chat = true, -- Show tool results directly in chat buffer
      --     format_tool = nil, -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
      --     -- MCP Resources
      --     make_vars = true, -- Convert MCP resources to #variables for prompts
      --     -- MCP Prompts
      --     make_slash_commands = true, -- Add MCP prompts as /slash commands
      --   },
      -- },
    },
  },
  config = function(_, opts) require("codecompanion").setup(opts) end,
  specs = {
    {
      "rebelot/heirline.nvim",
      optional = true,

      opts = function(_, opts)
        opts.statusline = opts.statusline or {}
        local spinner_symbols = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        local astroui = require "astroui.status.hl"
        table.insert(opts.statusline, 5, {
          static = {
            n_requests = 0,
            spinner_index = 0,
            spinner_symbols = spinner_symbols,
            done_symbol = "✓",
            timer = nil, -- store timer handle
          },
          init = function(self)
            if self._cc_autocmds then return end
            self._cc_autocmds = true
            vim.api.nvim_create_autocmd("User", {
              pattern = "CodeCompanionRequestStarted",
              callback = function()
                self.n_requests = self.n_requests + 1
                vim.cmd "redrawstatus"
                -- Start timer if not running
                if not self.timer then
                  self.timer = vim.loop.new_timer()
                  self.timer:start(
                    0,
                    250,
                    vim.schedule_wrap(function()
                      if self.n_requests > 0 then
                        vim.cmd "redrawstatus"
                      else
                        if self.timer then
                          self.timer:stop()
                          self.timer:close()
                          self.timer = nil
                        end
                      end
                    end)
                  )
                end
              end,
            })
            vim.api.nvim_create_autocmd("User", {
              pattern = "CodeCompanionRequestFinished",
              callback = function()
                self.n_requests = math.max(0, self.n_requests - 1)
                vim.cmd "redrawstatus"
                -- Stop timer if no requests left
                if self.n_requests == 0 and self.timer then
                  self.timer:stop()
                  self.timer:close()
                  self.timer = nil
                end
              end,
            })
          end,
          provider = function(self)
            if not package.loaded["codecompanion"] then return nil end
            local symbol
            if self.n_requests > 0 then
              self.spinner_index = (self.spinner_index % #self.spinner_symbols) + 1
              symbol = self.spinner_symbols[self.spinner_index]
            else
              symbol = self.done_symbol
              self.spinner_index = 0
            end
            return ("%d %s "):format(self.n_requests, symbol)
          end,
          hl = function() return astroui.filetype_color() end,
        })
      end,
    },
    { "AstroNvim/astroui", opts = { icons = { CodeCompanion = "󱙺" } } },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        if not opts.mappings then opts.mappings = {} end
        opts.mappings.n = opts.mappings.n or {}
        opts.mappings.v = opts.mappings.v or {}
        opts.mappings.n[prefix] = { desc = require("astroui").get_icon("CodeCompanion", 1, true) .. "CodeCompanion" }
        opts.mappings.v[prefix] = { desc = require("astroui").get_icon("CodeCompanion", 1, true) .. "CodeCompanion" }
        opts.mappings.n[prefix .. "c"] = { "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle chat" }
        opts.mappings.v[prefix .. "c"] = { "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle chat" }
        opts.mappings.n[prefix .. "x"] = { "<cmd>CodeCompanionCLI Ask<cr>", desc = "Toggle cli with prompt" }
        opts.mappings.n[prefix .. "s"] = { "<cmd>CodeCompanionCLI<cr>", desc = "Toggle cli" }
        opts.mappings.v[prefix .. "x"] = { "<cmd>CodeCompanionCLI Ask<cr>", desc = "Toggle cli with prompt" }
        opts.mappings.n[prefix .. "p"] = { "<cmd>CodeCompanionActions<cr>", desc = "Open action palette" }
        opts.mappings.v[prefix .. "p"] = { "<cmd>CodeCompanionActions<cr>", desc = "Open action palette" }
        -- Normal mode mapping for CodeCompanion prompt
        opts.mappings.n[prefix .. "q"] = {
          function()
            local snacks = require "snacks"
            -- Show input prompt to user
            snacks.input({
              prompt = "Ask CodeCompanion: ",
            }, function(input)
              -- If input is not empty, run CodeCompanion command with input
              if input and input ~= "" then vim.cmd("CodeCompanion " .. vim.fn.escape(input, " ")) end
            end)
          end,
          desc = "Open inline assistant with prompt",
        }
        -- Visual mode mapping for CodeCompanion prompt
        opts.mappings.v[prefix .. "q"] = {
          function()
            local snacks = require "snacks"
            -- Show input prompt to user
            snacks.input({
              prompt = "Ask CodeCompanion: ",
            }, function(input)
              -- If input is not empty, run CodeCompanion command on selected text with input
              if input and input ~= "" then vim.cmd("'<,'>CodeCompanion " .. vim.fn.escape(input, " ")) end
            end)
          end,
          desc = "Open inline assistant with prompt",
        }
        opts.mappings.v[prefix .. "a"] = { "<cmd>CodeCompanionChat Add<cr>", desc = "Add selection to chat" }
      end,
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      optional = true,
      opts = function(_, opts)
        if not opts.file_types then opts.file_types = { "markdown" } end
        opts.file_types = require("astrocore").list_insert_unique(opts.file_types, { "codecompanion" })
      end,
    },
    {
      "OXY2DEV/markview.nvim",
      optional = true,
      opts = function(_, opts)
        if not opts.preview then opts.preview = {} end
        if not opts.preview.filetypes then opts.preview.filetypes = { "markdown", "quarto", "rmd" } end
        opts.preview.filetypes = require("astrocore").list_insert_unique(opts.preview.filetypes, { "codecompanion" })
      end,
    },
  },
}
