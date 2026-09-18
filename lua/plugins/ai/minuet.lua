-- Picker changes are session-local; edit this for the startup model.
local default_model = "mellum"

local function qwen_prompt(before, after)
  return "<|fim_prefix|>" .. before .. "<|fim_suffix|>" .. after .. "<|fim_middle|>"
end

local qwen_stop = { "<|endoftext|>", "<|fim_prefix|>", "<|fim_suffix|>", "<|fim_middle|>", "<|file_sep|>" }
local models = {
  ["qwen-fast"] = {
    name = "Qwen2.5-Coder 1.5B Q8 (fast)",
    model = "ggml-org/Qwen2.5-Coder-1.5B-Q8_0-GGUF:Q8_0",
    prompt = qwen_prompt,
    stop = qwen_stop,
  },
  ["qwen-3b"] = {
    name = "Qwen2.5-Coder 3B Q8",
    model = "ggml-org/Qwen2.5-Coder-3B-Q8_0-GGUF:Q8_0",
    prompt = qwen_prompt,
    stop = qwen_stop,
  },
  mellum = {
    name = "Mellum 4B Q8",
    model = "JetBrains/Mellum-4b-base-gguf:Q8_0",
    prompt = function(before, after)
      -- Mellum uses suffix-first FIM and different tokens from Qwen.
      local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
      return "<filename>" .. filename .. "\n<fim_suffix>" .. after .. "<fim_prefix>" .. before .. "<fim_middle>"
    end,
    stop = { "<|endoftext|>", "<fim_prefix>", "<fim_suffix>", "<fim_middle>", "<fim_pad>", "<filename>" },
  },
}

local presets = {}
for key, model in pairs(models) do
  presets[key] = {
    provider = "openai_fim_compatible",
    provider_options = {
      openai_fim_compatible = {
        name = model.name,
        model = model.model,
        -- llama.cpp needs explicit FIM tokens, not an OpenAI suffix field.
        template = { prompt = model.prompt, suffix = false },
        optional = { stop = model.stop },
      },
    },
  }
end

---@type LazySpec
return {
  "milanglacier/minuet-ai.nvim",
  version = false, -- Track upstream main; lazy-lock.json records the installed revision.
  event = { "BufReadPre", "BufNewFile" }, -- Register autotrigger before the first FileType event.
  cmd = "Minuet",
  opts = function()
    local selected = assert(presets[default_model], "Unknown Minuet startup model: " .. default_model)
    return vim.tbl_deep_extend("force", {
      presets = presets,
      provider = "openai_fim_compatible",
      n_completions = 1,
      context_window = 4096, -- Characters, not tokens; keep prompt processing cheap.
      debounce = 100,
      throttle = 200,
      -- Do not complete inside the model picker, terminals, or other UI buffers.
      enable_predicates = { function() return vim.bo.buftype == "" end },
      request_timeout = 2,
      virtualtext = {
        auto_trigger_ft = { "*" },
        keymap = {
          accept = "<A-a>",
          accept_line = "<A-l>",
          next = "<A-]>",
          prev = "<A-[>",
          dismiss = "<A-d>", -- <A-e> belongs to nvim-autopairs fast-wrap.
        },
      },
      -- No next-edit requests or background edit-history recorder.
      duet = {
        auto_trigger = { auto_trigger_ft = {} },
        recent_edits = { enabled = false },
      },
      provider_options = {
        openai_fim_compatible = {
          end_point = "http://127.0.0.1:8080/v1/completions",
          api_key = function() return "local" end,
          stream = true,
          optional = {
            max_tokens = 64,
            temperature = 0,
            cache_prompt = true,
          },
        },
      },
    }, selected)
  end,
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        options = {
          g = {
            -- AstroCommunity's AI recipe gives snippet jumps priority over AI.
            ai_accept = function()
              local virtualtext = package.loaded["minuet.virtualtext"]
              if virtualtext and virtualtext.action.is_visible() then
                vim.schedule(virtualtext.action.accept_line)
                return true
              end
            end,
          },
        },
        mappings = {
          n = {
            ["<Leader>at"] = { "<Cmd>Minuet virtualtext toggle<CR>", desc = "Toggle Minuet completion (buffer)" },
            ["<Leader>am"] = {
              function()
                local minuet = require "minuet"
                vim.ui.select(vim.tbl_keys(models), {
                  prompt = "Completion model (this session)",
                  format_item = function(key)
                    local active = minuet.config.provider_options.openai_fim_compatible.model == models[key].model
                    return models[key].name .. (active and " (active)" or "")
                  end,
                }, function(key)
                  if not key then return end
                  require("minuet.backends.common").terminate_all_jobs()
                  require("minuet.virtualtext").action.dismiss()
                  minuet.change_preset(key)
                end)
              end,
              desc = "Choose completion model",
            },
          },
        },
      },
    },
  },
}
