local ls = require "luasnip"
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local t = ls.text_node

-- -------------------------
-- Helpers
-- -------------------------

-- Get component name from filename
local function component_from_filename()
  local name = vim.fn.expand("%:t"):gsub("%..+$", "") -- remove extension
  if name == "" then return "ExampleComponent" end
  -- snake_case / kebab-case -> PascalCase
  name = name:gsub("[-_](.)", function(c) return c:upper() end)
  name = name:gsub("^%l", string.upper)
  return name
end

-- Get Java package from LSP (fallback to buffer scan)

local function java_package()
  local filepath = vim.fn.expand "%:p"
  if filepath == "" then return {} end

  local parts = vim.split(filepath, "/")
  local pkg_parts = {}
  local found_com = false

  for i = #parts, 1, -1 do
    local part = parts[i]
    if part == "com" then
      found_com = true
      table.insert(pkg_parts, 1, part)
      break
    end
    if found_com then break end
    table.insert(pkg_parts, 1, part)
  end

  if not found_com then return {} end

  -- Remove filename
  pkg_parts[#pkg_parts] = nil

  local package_name = table.concat(pkg_parts, ".")

  return {
    "package " .. package_name .. ";",
    "",
    "",
  }
end

-- PipeComponent -> getPipeType
local function component_type_name(args)
  local class = args[1][1]
  local base = class:gsub("Component$", "")
  return "get" .. base .. "Type"
end

-- -------------------------
-- Snippets
-- -------------------------

return {

  s("chunkcomp", {

    f(java_package),

    t {
      "import com.hypixel.hytale.codec.Codec;",
      "import com.hypixel.hytale.codec.KeyedCodec;",
      "import com.hypixel.hytale.codec.builder.BuilderCodec;",
      "import com.hypixel.hytale.codec.validation.Validators;",
      "import com.hypixel.hytale.component.Component;",
      "import com.hypixel.hytale.component.ComponentType;",
      "import com.hypixel.hytale.server.core.universe.world.storage.ChunkStore;",
      "",
      "",
    },

    t { "public class " },
    i(1, component_from_filename()),
    t { " implements Component<ChunkStore> {", "" },

    t { "  public static final BuilderCodec<" },
    f(function(args) return args[1][1] end, { 1 }),
    t { "> CODEC = BuilderCodec.builder(" },
    f(function(args) return args[1][1] end, { 1 }),
    t { ".class, " },
    f(function(args) return args[1][1] end, { 1 }),
    t { "::new)", "      .build();", "" },

    t { "  public " },
    f(function(args) return args[1][1] end, { 1 }),
    t { "() {", "  }", "" },

    t { "  public " },
    f(function(args) return args[1][1] end, { 1 }),
    t { "(" },
    f(function(args) return args[1][1] end, { 1 }),
    t { " other) {", "  }", "" },

    t {
      "  @Override",
      "  public Component<ChunkStore> clone() {",
      "    return new ",
    },
    f(function(args) return args[1][1] end, { 1 }),
    t { "(this);", "  }", "" },

    t { "  public static ComponentType<ChunkStore, " },
    f(function(args) return args[1][1] end, { 1 }),
    t { "> " },
    f(component_type_name, { 1 }),
    t {
      "() {",
      "    return ",
    },
    i(2, "MSPlugin"),
    t { ".get()." },
    f(component_type_name, { 1 }),
    t { "();", "  }", "}" },

    i(0),
  }),
  s("entcomp", {

    f(java_package),

    t {
      "import com.hypixel.hytale.codec.Codec;",
      "import com.hypixel.hytale.codec.KeyedCodec;",
      "import com.hypixel.hytale.codec.builder.BuilderCodec;",
      "import com.hypixel.hytale.codec.validation.Validators;",
      "import com.hypixel.hytale.component.Component;",
      "import com.hypixel.hytale.component.ComponentType;",
      "import com.hypixel.hytale.server.core.universe.world.storage.EntityStore;",
      "",
      "",
    },

    t { "public class " },
    i(1, component_from_filename()),
    t { " implements Component<EntityStore> {", "" },

    t { "  public static final BuilderCodec<" },
    f(function(args) return args[1][1] end, { 1 }),
    t { "> CODEC = BuilderCodec.builder(" },
    f(function(args) return args[1][1] end, { 1 }),
    t { ".class, " },
    f(function(args) return args[1][1] end, { 1 }),
    t { "::new)", "      .build();", "" },

    t { "  public " },
    f(function(args) return args[1][1] end, { 1 }),
    t { "() {", "  }", "" },

    t { "  public " },
    f(function(args) return args[1][1] end, { 1 }),
    t { "(" },
    f(function(args) return args[1][1] end, { 1 }),
    t { " other) {", "  }", "" },

    t {
      "  @Override",
      "  public Component<EntityStore> clone() {",
      "    return new ",
    },
    f(function(args) return args[1][1] end, { 1 }),
    t { "(this);", "  }", "" },

    t { "  public static ComponentType<EntityStore, " },
    f(function(args) return args[1][1] end, { 1 }),
    t { "> " },
    f(component_type_name, { 1 }),
    t {
      "() {",
      "    return ",
    },
    i(2, "MSPlugin"),
    t { ".get()." },
    f(component_type_name, { 1 }),
    t { "();", "  }", "}" },

    i(0),
  }),
  s("entsystem", {

    f(java_package),

    t {
      "import com.hypixel.hytale.component.Component;",
      "import com.hypixel.hytale.component.ComponentType;",
      "import com.hypixel.hytale.server.core.universe.world.storage.EntityStore;",
      "import com.hypixel.hytale.component.query.Query;",
      "import com.hypixel.hytale.component.system.tick.EntityTickingSystem;",
      "import com.hypixel.hytale.component.ArchetypeChunk;",
      "import com.hypixel.hytale.component.CommandBuffer;",
      "import com.hypixel.hytale.component.ComponentType;",
      "import com.hypixel.hytale.component.Store;",
      "",
      "",
    },

    t { "public class " },
    i(1, component_from_filename()),
    t { " extends EntityTickingSystem<EntityStore> {", "" },

    t { "  public " },
    f(function(args) return args[1][1] end, { 1 }),
    t { "() {", "  }", "" },
    t { "}", "" },
  }),
}
