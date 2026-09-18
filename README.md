# Neovim configuration

Personal configuration built on AstroNvim v6 and lazy.nvim. Plugin revisions are pinned in `lazy-lock.json`.

## Where things live

| Path | Responsibility |
| --- | --- |
| `init.lua` | Bootstrap Lazy, then load configuration and final autocmds |
| `lua/config/lazy.lua` | AstroNvim setup and Lazy settings |
| `lua/config/plugins.lua` | **Plugin switches, community packs, profiles, and hard exclusions** |
| `lua/config/options.lua` | Editor options |
| `lua/config/mappings.lua` | General editor mappings; plugin-specific keys stay with their specs |
| `lua/config/autocmds.lua` | Final startup autocmds, including LSP inline completion |
| `lua/config/gist.lua` | GitHub gist actions used by editor mappings |
| `lua/plugins/core/` | AstroCore, shared LSP and Treesitter settings |
| `lua/plugins/ui/` | Theme/statusline, Snacks picker/explorer/dashboard, layout |
| `lua/plugins/editing/` | Completion, snippets, text objects and surrounding |
| `lua/plugins/languages/` | Language-specific servers, parsers and integrations |
| `lua/plugins/tools/` | Mason, formatters, debugger configurations and productivity integration |
| `lua/plugins/ai/` | Minuet, OMP, and disabled AI alternatives |
| `lua/user/` | Custom parameter-renaming helper and local AI model selection |
| `snippets/luasnips/` | Java, Rust and Odin snippets; paths follow the active config directory |
| `extpluginforks/` | Local plugin source, separate from plugin configuration |
| `lua/llama/` | Retained, currently unused local Llama integration |

Loading order: AstroNvim → selected community packs → local core, UI, editing, tools, languages, AI → hard exclusions → final autocmds. Local modules are alphabetical within each group. `lua/plugins/init.lua` imports only the modules selected in `config/plugins.lua`; category directories are not recursively imported.

## Profiles

```sh
nvim                      # personal (default)
NVIM_PROFILE=work nvim     # smaller starting point for a work configuration
NVIM_PROFILE=school nvim   # C# coursework and Markdown class notes
```

The personal profile keeps the existing active plugin selections, theme, completion keys and local AI endpoints. Disabled AI experiments remain disabled. Stale always-on CodeCompanion visual shortcuts were removed; its shortcuts now belong only to its disabled plugin spec.

The work profile keeps the editor/UI, completion, snippets, Lua and Python packs. It omits AI (including Minuet and OMP), the productivity integration, No Neck Pain, debugging, and the extra game/shader/C#/Odin/Rust/C++/web language selections. It is an editable starting point, not a workplace security policy or a separate Neovim installation.

The school profile keeps the existing Roslyn C# setup, C# syntax parser, Markdown rendering, No Neck Pain, completion, snippets, undo history and the normal editor/UI. It disables all AI, debugging, the productivity integration, and every other language selection. Basic Lua parsing, language-server and formatting tools remain for maintaining this configuration. It adds no dependencies and uses the existing `roslyn-language-server` executable and Markdown parsers.

Edit `profiles.work` or `profiles.school` in `lua/config/plugins.lua` to choose the languages and tools you actually use. Profile module values override the defaults, but a disabled group wins over an enabled module. Restart Neovim to apply changes. Unknown profile names produce an error rather than silently loading personal plugins.

**Profiles share installed plugins, state and the lockfile by default.** Do not run `:Lazy clean` or `:Lazy sync` in the work or school profile unless you intend to remove plugins used by the personal profile. Updates can also prune lock entries for plugins absent from the active profile. Use the personal profile for dependency maintenance, or use a separate copy for work:

```sh
# Copy this repository to ~/.config/nvim-work first, then:
NVIM_APPNAME=nvim-work NVIM_PROFILE=work nvim
```

`NVIM_APPNAME` gives the work copy its own config/data/state/cache paths. Its first launch installs its selected plugins. Set `NVIM_PROFILE=work` in your work launcher/shell so the copy does not default to the personal profile.

## Disable, remove or add plugins

All selection controls are in `lua/config/plugins.lua`:

- **One local module:** set its entry in `modules` to `false`, such as `["ai.minuet"] = false`. The spec is not evaluated and its own settings/keys are not registered.
- **A whole group:** set `groups.ai = false`, or set the group in a profile. Community selections such as the AI recipe follow the same group switch.
- **A community pack:** set its named module switch to `false`, such as `["languages.rust"] = false`.
- **An upstream/dependency plugin:** add its full repository name to `disabled`, or a profile's `disabled` list. This emits Lazy's `enabled = false`. Disabling a local customization does **not** remove a plugin that AstroNvim or a community pack also supplies.
- **Remove a configuration file:** remove its module entry as well, or leave the entry `false`. Do not leave an enabled import pointing to a deleted file.

AstroNvim is still the base distribution: turning off a `core`/`ui`/`editing` group removes this repository's customizations, not every underlying AstroNvim plugin. When excluding base plugins directly, also account for consumers such as completion's snippet provider or the statusline.

To add a plugin, create a normal LazySpec in the appropriate category and add its dotted module name to `modules`. For example, `lua/plugins/editing/example.lua` is selected by `["editing.example"] = true`. Keep related mappings under that plugin's `keys` or its AstroCore `specs`, and extend list-valued options with `astrocore.list_insert_unique` rather than overwriting other modules' lists. Community additions need an entry in both `community` and `modules`.

Do not restore per-file `if true then return {} end` guards or another `disabled.lua`; the registry is the source of truth.

## Personal integrations and requirements

- Minuet: `lua/plugins/ai/minuet.lua`; upstream inline FIM completion through the local llama.cpp router. CursorTab and the old local Minuet experiment (`ai.cmp_ai`) are disabled. Do not enable multiple inline completion providers together.
- OMP: `lua/plugins/ai/omp.lua` installs the pinned integration; `ai/terminal.lua` owns `<leader>ao` and requires the `omp` executable.
- Other AI configurations: retained but untested when enabled. Check their endpoints, dependencies and overlapping `<leader>a` keys before selecting multiple assistants. Copilot remains hard-excluded unless removed from `disabled`.
- C#: `languages.csharp` is the current direct Roslyn LSP setup; `csharp-ls` and `roslyn-plugin` are disabled alternatives. Select only one implementation.
- Gists/GitHub pickers require an authenticated `gh` CLI. The private gist actions upload the current file/selection only when invoked.
- `<leader>fdb` retains the personal Bevy examples path in `ui/snacks.lua`; it is omitted when the Rust selection is disabled.
- Local plugin forks and custom snippets were retained, not rewritten as part of the layout cleanup.

## Local autocomplete

Minuet starts with Qwen2.5-Coder 1.5B Q8 at `http://127.0.0.1:8080/v1/completions`. Use `<leader>am` to choose Qwen 1.5B, Qwen 3B, or Mellum 4B Q8 for the current session. To change the startup choice, edit `default_model` at the top of `lua/plugins/ai/minuet.lua`: `"qwen-fast"`, `"qwen-3b"`, or `"mellum"`. Model definitions and FIM formats live in the same file, independently of the selector used by disabled AI experiments. Minuet tracks upstream main, with its installed revision recorded in `lazy-lock.json`.

Completion uses one request, a 4,096-character context, a 64-token output cap, deterministic sampling, a 100 ms debounce, and a 200 ms throttle. Blink/LSP completion remains separate. Minuet Duet automatic prediction and edit-history recording are disabled; no next-edit model is used.

| Key | Action |
| --- | --- |
| `Tab` | Jump forward in a snippet first; otherwise accept **one line** of visible AI completion; otherwise normal Tab |
| `Shift-Tab` | Jump backward in a snippet; otherwise normal fallback |
| `Alt-a` | Accept the whole AI suggestion |
| `Alt-l` | Accept one line |
| `Alt-]` / `Alt-[` | Request a suggestion or cycle suggestions |
| `Alt-d` | Dismiss the suggestion |
| `<leader>at` | Toggle automatic Minuet completion for the current buffer |
| `<leader>am` | Choose the completion model for this session |

`Alt-e` remains nvim-autopairs fast-wrap. Suggestions are hidden while Blink's completion menu is open. Automatic requests are restricted to normal file buffers, so typing in the model picker does not call the model.

The model must be available in the existing llama.cpp router. On a new machine with the same router setup, download it through the router API:

```sh
curl -f http://127.0.0.1:8080/models \
  -H 'Content-Type: application/json' \
  -d '{"model":"ggml-org/Qwen2.5-Coder-1.5B-Q8_0-GGUF:Q8_0"}'
```

This starts an asynchronous download; inspect `GET /models` or `/models/sse` before requesting completion. A router at its loaded-model limit may require unloading an idle model first. The plugin does not launch the server or download models during Neovim startup.

All three model weights are downloaded on this machine. The picker changes the model, FIM prompt format, and stop tokens together; Mellum uses `<filename>` plus suffix-first `<fim_suffix>…<fim_prefix>…<fim_middle>`, not Qwen's `<|fim_*|>` tokens. You can also use `:Minuet change_preset qwen-fast`, `:Minuet change_preset qwen-3b`, or `:Minuet change_preset mellum`. Prefer presets over changing only the raw model ID.

**Mellum requires a router context override.** The router's global 32K context allocates an approximately 11 GB KV cache for Mellum and fails to fit alongside its weights on the 4080. Add this section to the existing `~/bin/models_config.ini`, then reload the router's model list:

```ini
[JetBrains/Mellum-4b-base-gguf:Q8_0]
hf = JetBrains/Mellum-4b-base-gguf:Q8_0
ctx-size = 4096
```

```sh
curl -fsS 'http://127.0.0.1:8080/models?reload=1' >/dev/null
```

The router configuration was read-only during setup, so that override must be applied outside the sandbox before selecting Mellum on port 8080. Mellum was verified using a temporary 4K-context server: Rust/Odin samples passed compiler checks, and Minuet displayed and accepted its Odin suggestion. This is not a broad language/API benchmark.

The existing router loads at most one model and sleeps idle models after 260 seconds. Switching to a chat model or returning after sleep can therefore introduce a cold start. Initial local measurements were about 1.2–1.4 seconds to load these models, versus tens of milliseconds for short warm completions. These timings exclude the editor debounce; Minuet's request timeout is two seconds. For consistently warm latency, a dedicated completion server is preferable to sharing a single-model router.

## Formatting and maintenance

```sh
stylua init.lua lua/config lua/plugins
```

Use `:Lazy` to inspect the active selection and `:checkhealth` for machine-specific dependencies. Plugin or model downloads and external services are separate from configuration loading; the work and school profiles do not require an AI service.
