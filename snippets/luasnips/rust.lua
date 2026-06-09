local ls = require "luasnip"

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("plugin", {
    t {
      "use bevy::prelude::*;",
      "",
      "pub(super) fn plugin(app: &mut App) {",
    },
    t "\t",
    i(0),
    t { "", "}" },
  }),

  s("component", {
    t {
      "#[derive(Component, Reflect, Debug)]",
      "#[reflect(Component)]",
    },
    t "struct ",
    i(1, "Name"),
    t ";",
    i(0),
  }),

  s("resource", {
    t {
      "#[derive(Resource, Reflect, Debug, Default)]",
      "#[reflect(Resource)]",
    },
    t "struct ",
    i(1, "Name"),
    t ";",
    i(0),
  }),

  s("event", {
    t {
      "#[derive(Event, Debug)]",
    },
    t "struct ",
    i(1, "Name"),
    t ";",
    i(0),
  }),

  s("systemset", {
    t {
      "#[derive(SystemSet, Copy, Clone, Eq, PartialEq, Hash, Debug)]",
      "enum ",
    },
    i(1, "Name"),
    t { " {", "\t" },
    i(0),
    t { "", "}" },
  }),

  s("schedule", {
    t {
      "#[derive(ScheduleLabel, Copy, Clone, Eq, PartialEq, Hash, Debug)]",
    },
    t "struct ",
    i(1, "Name"),
    t ";",
    i(0),
  }),

  s("states", {
    t {
      "#[derive(States, Copy, Clone, Eq, PartialEq, Hash, Debug, Default)]",
      "enum ",
    },
    i(1, "Name"),
    t { " {", "\t#[default]", "\t" },
    i(0),
    t { "", "}" },
  }),
}
