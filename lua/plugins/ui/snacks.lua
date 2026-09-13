local function focus_previous_window()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>p", true, true, true), "n", true)
end

local function open_explorer()
  require("snacks").explorer.open()
  -- Refresh No Neck Pain after opening, without flickering when the explorer closes.
  vim.defer_fn(function()
    if require("snacks").picker.get({ source = "explorer" })[1] then
      focus_previous_window()
      vim.defer_fn(focus_previous_window, 50)
    end
  end, 50)
end

---@type LazySpec
return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    picker = {
      matcher = {
        frecency = true,
      },
      exclude = {
        "*.uid",
      },
    },
    dashboard = {
      sections = {
        { section = "header" },
        { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
        { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        {
          pane = 2,
          icon = " ",
          title = "Git Status",
          section = "terminal",
          enabled = function() return Snacks.git.get_root() ~= nil end,
          cmd = "git status --short --branch --renames",
          height = 5,
          padding = 1,
          ttl = 5 * 60,
          indent = 3,
        },
        { section = "startup" },
      },
    },
  },
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        opts.mappings = opts.mappings or {}
        opts.mappings.n = opts.mappings.n or {}
        local maps = opts.mappings.n

        maps["<leader>f;"] = {
          function()
            require("snacks").picker.grep {
              ignored = true,
              follow = true,
              ft = { "java", "gdscript", "lua", "csharp", "python", "rust", "go" },
            }
          end,
          desc = "Find in Programming Language",
        }
        maps["<leader>f,"] = {
          function()
            require("snacks").picker.grep {
              need_search = false,
              dirs = { vim.api.nvim_buf_get_name(0) },
              layout = {
                preset = "ivy",
              },
              format = function(item)
                local ret = { { string.format("%s: ", item.pos[1]), "Conceal" } }
                require("snacks").picker.highlight.format(item, item.line, ret)
                return ret
              end,
            }
          end,
          desc = "Find in Current File",
        }
        if require("config.plugins").enabled "languages.rust" then
          maps["<leader>fdb"] = {
            -- Search inside personal Bevy examples.
            function()
              require("snacks").picker.grep {
                cwd = "/mnt/8tbhdd/Projects/Programming/Rust/bevy/examples",
                layout = {
                  preset = "ivy",
                },
              }
            end,
          }
        end

        maps["grr"] = { function() require("snacks").picker.lsp_references() end, desc = "Search References" }
        maps["grd"] = { function() require("snacks").picker.lsp_definitions() end, desc = "Go to Definition" }
        maps["grw"] = {
          function() require("snacks").picker.lsp_workspace_symbols() end,
          desc = "Workspace Symbols",
        }
        maps["grD"] = { function() require("snacks").picker.lsp_declarations() end, desc = "Search Declarations" }
        maps["gri"] = {
          function() require("snacks").picker.lsp_implementations() end,
          desc = "Search Implementation",
        }
        maps["<leader>e"] = { open_explorer, desc = "Open Snacks File Picker" }
        maps["<leader>o"] = {
          function()
            local explorer = require("snacks").picker.get({ source = "explorer" })[1]
            if explorer then
              explorer:focus "list"
            else
              open_explorer()
            end
          end,
          desc = "Resume Snacks Picker",
        }
        -- Alternative file manager: ["<leader>o"] = { "<Cmd>Yazi cwd<CR>", desc = "Resume Yazi" }

        maps["<leader>gi"] = { function() require("snacks").picker.gh_issue() end, desc = "GitHub Issues (open)" }
        maps["<leader>gI"] = {
          function() require("snacks").picker.gh_issue { state = "all" } end,
          desc = "GitHub Issues (all)",
        }
        maps["<leader>gO"] = { function() require("snacks").picker.gh_pr() end, desc = "GitHub Pull Requests (open)" }
        maps["<leader>gP"] = {
          function() require("snacks").picker.gh_pr { state = "all" } end,
          desc = "GitHub Pull Requests (all)",
        }
      end,
    },
  },
}
