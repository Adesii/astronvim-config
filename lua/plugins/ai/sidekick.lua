prompts = {
  explain_selection = [[
Explain this selected section, including how it works and why it is written this way.
Do not modify code.

{selection}
]],

  review_selection = [[
Review this selected section for correctness, maintainability, and meaningful performance issues.
Provide concrete, actionable findings. Do not modify code.

{selection}
]],

  refactor_selection = [[
Refactor this selected section to make it clearer and easier to maintain.
Preserve behavior and public APIs. Avoid unrelated changes.

{selection}
]],

  rust_borrow = [[
Fix the Rust borrow-checker or lifetime errors in {file}.
Diagnostics:
{diagnostics}

Make the smallest reasonable changes while preserving the existing
architecture, behavior, and public API.

Prefer:
- Shortening borrow scopes
- Splitting disjoint borrows
- Moving values or using owned data when appropriate
- Localized restructuring

Avoid:
- Unnecessary cloning or allocations
- Introducing Arc, Mutex, RefCell, or unsafe without justification
- New traits, generics, or architectural rewrites

Apply the fix and briefly explain the underlying ownership conflict.
]],

  rust_simplify = [[
Review {this} and identify unnecessary Rust complexity.

Look for:
- Generics or traits that could be replaced with concrete types
- Overly complicated lifetime relationships
- Excessive abstraction layers
- Unnecessary wrappers and indirection

Simplify where it genuinely improves readability and maintainability.
Preserve functionality, performance characteristics, and public APIs
unless a change is clearly justified.
Don't sacrifice useful abstractions just to reduce line count.
]],

  rust_refactor = [[
Refactor {this} to make future changes easier.

Prioritize extensibility, clear ownership boundaries, and readability.
Preserve existing behavior and avoid unrelated changes.

Do not introduce new architectural patterns unless the current design
has a concrete limitation.

Prefer ordinary functions, structs, enums, and explicit data flow.
Explain any significant structural changes.
]],

  rust_ownership = [[
Analyze the ownership and borrowing relationships in {this}.

Explain:
1. Who owns the important values
2. Where borrows begin and end
3. Which relationships might become restrictive
4. Whether simpler ownership boundaries would help

Suggest minimal improvements.
Do not modify code unless asked.
]],

  rust_perf = [[
Review {this} for meaningful performance issues.

Focus on:
- Unnecessary allocations and clones
- Repeated lookups or expensive operations
- Poor data locality
- Lock contention and synchronization
- Algorithmic complexity

Distinguish confirmed issues from potential bottlenecks.
Avoid speculative micro-optimizations.
Recommend profiling when appropriate.
]],

  rust_extend = [[
Help extend the current implementation in {file}.

Preserve the existing architecture where practical.
Identify the smallest change that supports the new requirement.

Avoid rewriting working systems, introducing speculative
abstractions, or adding generic infrastructure for future features.

First explain the relevant extension points and tradeoffs.
Wait for the feature requirements if they are not yet provided.
]],

  rust_explain = [[
Explain {this} in practical terms.

Focus on why Rust requires this implementation,
especially ownership, borrowing, lifetimes, and trait constraints.

Compare with a simpler alternative where useful.
Point out which complexity is essential and which is optional.

Do not modify code.
]],

  rust_review = [[
Review {file} as an experienced Rust developer.

Prioritize:
1. Correctness and actual bugs
2. Ownership and lifetime complexity
3. Maintainability and ease of extension
4. Performance concerns supported by evidence
5. Idiomatic Rust where it genuinely improves the code

Do not recommend changes purely for stylistic reasons.
Provide concrete, actionable findings.
Do not modify code.
]],
}

return {
  "folke/sidekick.nvim",
  opts = {
    cli = {
      prompts = prompts,
      tools = {
        somp = {
          cmd = { "somp", "." },
          resume = "--resume",
          continue = "--continue",
          native_scroll = false,
        },
      },
    },
    nes = {
      enabled = true,
    },
    copilot = {
      status = {
        level = vim.log.levels.INFO,
      },
    },
    debug = false,
  },
  config = function(_, opts)
    require("sidekick").setup(opts)
    -- Setup deep-merges built-in tools; false entries do not disable them.
    require("sidekick.config").cli.tools = { somp = opts.cli.tools.somp }
  end,
  specs = {
    {
      "AstroNvim/astrocore",
      ---@param opts AstroCoreOpts
      opts = function(_, opts)
        local maps = assert(opts.mappings)
        local prefix = "<Leader>a"
        maps.v = maps.v or {}

        -- Prompt selection works in both normal and visual mode.
        maps.n[prefix] = { desc = require("astroui").get_icon("Sidekick", 1, true) .. "AI" }
        maps.v[prefix] = { desc = require("astroui").get_icon("Sidekick", 1, true) .. "AI" }

        maps.n[prefix .. "p"] = {
          function()
            local cli = require "sidekick.cli"
            cli.prompt {
              cb = function(_, text)
                if text then cli.send { name = "somp", text = text } end
              end,
            }
          end,
          desc = "Prompt",
        }
        maps.v[prefix .. "p"] = maps.n[prefix .. "p"]
        maps.n[prefix .. "c"] = { function() require("sidekick.cli").close { name = "somp" } end, desc = "Close" }
        maps.n[prefix .. "s"] = { function() require("sidekick.cli").show { name = "somp" } end, desc = "Show" }

        maps.n[prefix .. "n"] = { desc = require("astroui").get_icon("SidekickBrain", 1, true) .. "NES" }
        maps.n[prefix .. "nt"] = {
          function() require("sidekick.nes").toggle() end,
          desc = "Toggle NES",
        }
        maps.n[prefix .. "ne"] = {
          function() require("sidekick.nes").enable() end,
          desc = "Enable NES",
        }
        maps.n[prefix .. "nd"] = {
          function() require("sidekick.nes").disable() end,
          desc = "Disable NES",
        }
        maps.n[prefix .. "nu"] = {
          function() require("sidekick.nes").update() end,
          desc = "Update Suggestions",
        }

        maps.n["<Tab>"] = {
          function()
            if not require("sidekick").nes_jump_or_apply() then return "<Tab>" end
          end,
          expr = true,
          desc = "Goto/Apply Next Edit Suggestion",
        }
      end,
    },
    {
      "Saghen/blink.cmp",
      opts = function(_, opts)
        opts.keymap["<Tab>"] = {
          "snippet_forward",
          function() return vim.lsp.inline_completion.get() end,
          "fallback",
        }
      end,
    },
    { "AstroNvim/astroui", opts = { icons = { Sidekick = "", SidekickBrain = "󰧑" } } },
  },
}
