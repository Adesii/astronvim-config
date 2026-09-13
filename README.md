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
| `lua/plugins/ai/` | CursorTab, OMP, and disabled AI experiments |
| `lua/user/` | Custom parameter-renaming helper and local AI model selection |
| `snippets/luasnips/` | Java, Rust and Odin snippets; paths follow the active config directory |
| `extpluginforks/` | Local plugin source, separate from plugin configuration |
| `lua/llama/` | Retained, currently unused local Llama integration |

Loading order: AstroNvim → selected community packs → local core, UI, editing, tools, languages, AI → hard exclusions → final autocmds. Local modules are alphabetical within each group. `lua/plugins/init.lua` imports only the modules selected in `config/plugins.lua`; category directories are not recursively imported.

## Profiles

```sh
nvim                      # personal (default)
NVIM_PROFILE=work nvim     # smaller starting point for a work configuration
```

The personal profile keeps the existing active plugin selections, theme, completion keys and local AI endpoints. Disabled AI experiments remain disabled. Stale always-on CodeCompanion visual shortcuts were removed; its shortcuts now belong only to its disabled plugin spec.

The work profile keeps the editor/UI, completion, snippets, Lua and Python packs. It omits AI (including CursorTab and OMP), the productivity integration, No Neck Pain, debugging, and the extra game/shader/C#/Odin/Rust/C++/web language selections. It is an editable starting point, not a workplace security policy or a separate Neovim installation.

Edit `profiles.work` in `lua/config/plugins.lua` to choose the languages and tools you actually use. Profile module values override the defaults, but a disabled group wins over an enabled module. Restart Neovim to apply changes. Unknown profile names produce an error rather than silently loading personal plugins.

**Profiles share installed plugins, state and the lockfile by default.** Do not run `:Lazy clean` or `:Lazy sync` in the smaller profile unless you intend to remove plugins used by the personal profile. Updates can also prune lock entries for plugins absent from the active profile. Use the personal profile for dependency maintenance, or use a separate copy for work:

```sh
# Copy this repository to ~/.config/nvim-work first, then:
NVIM_APPNAME=nvim-work NVIM_PROFILE=work nvim
```

`NVIM_APPNAME` gives the work copy its own config/data/state/cache paths. Its first launch installs its selected plugins. Set `NVIM_PROFILE=work` in your work launcher/shell so the copy does not default to the personal profile.

## Disable, remove or add plugins

All selection controls are in `lua/config/plugins.lua`:

- **One local module:** set its entry in `modules` to `false`, such as `["ai.cursortab"] = false`. The spec is not evaluated and its own settings/keys are not registered.
- **A whole group:** set `groups.ai = false`, or set the group in a profile. Community selections such as the AI recipe follow the same group switch.
- **A community pack:** set its named module switch to `false`, such as `["languages.rust"] = false`.
- **An upstream/dependency plugin:** add its full repository name to `disabled`, or a profile's `disabled` list. This emits Lazy's `enabled = false`. Disabling a local customization does **not** remove a plugin that AstroNvim or a community pack also supplies.
- **Remove a configuration file:** remove its module entry as well, or leave the entry `false`. Do not leave an enabled import pointing to a deleted file.

AstroNvim is still the base distribution: turning off a `core`/`ui`/`editing` group removes this repository's customizations, not every underlying AstroNvim plugin. When excluding base plugins directly, also account for consumers such as completion's snippet provider or the statusline.

To add a plugin, create a normal LazySpec in the appropriate category and add its dotted module name to `modules`. For example, `lua/plugins/editing/example.lua` is selected by `["editing.example"] = true`. Keep related mappings under that plugin's `keys` or its AstroCore `specs`, and extend list-valued options with `astrocore.list_insert_unique` rather than overwriting other modules' lists. Community additions need an entry in both `community` and `modules`.

Do not restore per-file `if true then return {} end` guards or another `disabled.lua`; the registry is the source of truth.

## Personal integrations and requirements

- CursorTab: `lua/plugins/ai/cursortab.lua`; retains its local Zeta endpoint/settings and Go build step.
- OMP: `lua/plugins/ai/omp.lua` installs the pinned integration; `ai/terminal.lua` owns `<leader>ao` and requires the `omp` executable.
- Other AI configurations: retained but untested when enabled. Check their endpoints, dependencies and overlapping `<leader>a` keys before selecting multiple assistants. Copilot remains hard-excluded unless removed from `disabled`.
- C#: `languages.csharp` is the current direct Roslyn LSP setup; `csharp-ls` and `roslyn-plugin` are disabled alternatives. Select only one implementation.
- Gists/GitHub pickers require an authenticated `gh` CLI. The private gist actions upload the current file/selection only when invoked.
- `<leader>fdb` retains the personal Bevy examples path in `ui/snacks.lua`; it is omitted when the Rust selection is disabled.
- Local plugin forks and custom snippets were retained, not rewritten as part of the layout cleanup.

## Formatting and maintenance

```sh
stylua init.lua lua/config lua/plugins
```

Use `:Lazy` to inspect the active selection and `:checkhealth` for machine-specific dependencies. Plugin or model downloads and external services are separate from configuration loading; the work profile does not require an AI service.
