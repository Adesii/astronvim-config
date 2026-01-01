local ls = require "luasnip"

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local sn = ls.snippet_node
local fmt = require("luasnip.extras.fmt").fmt

return {

  -- procedure
  s(
    "proc",
    fmt(
      [[
{} :: proc({}) {} {{
  {}
}}
]],
      {
        i(1, "name"),
        i(2),
        c(3, { t "", sn(nil, { t "-> ", i(1) }) }),
        i(0),
      }
    )
  ),

  -- main procedure
  s(
    "main",
    fmt(
      [[
main :: proc() {{
  {}
}}
]],
      {
        i(0),
      }
    )
  ),

  -- for loop (range)
  s(
    "for",
    fmt(
      [[
for {} in {} {{
  {}
}}
]],
      {
        i(1, "x"),
        i(2, "collection"),
        i(0),
      }
    )
  ),

  -- for loop (classic)
  s(
    "fori",
    fmt(
      [[
for {} := {}; {} < {}; {} += {} {{
  {}
}}
]],
      {
        i(1, "i"),
        i(2, "0"),
        i(1),
        i(3, "n"),
        i(1),
        i(4, "1"),
        i(0),
      }
    )
  ),

  -- if statement
  s(
    "if",
    fmt(
      [[
if {} {{
  {}
}}
]],
      {
        i(1, "condition"),
        i(0),
      }
    )
  ),

  -- if / else
  s(
    "ife",
    fmt(
      [[
if {} {{
  {}
}} else {{
  {}
}}
]],
      {
        i(1, "condition"),
        i(2),
        i(0),
      }
    )
  ),

  -- struct
  s(
    "struct",
    fmt(
      [[
{} :: struct {{
  {}
}}
]],
      {
        i(1, "Name"),
        i(0),
      }
    )
  ),

  -- enum
  s(
    "enum",
    fmt(
      [[
{} :: enum {{
  {}
}}
]],
      {
        i(1, "Name"),
        i(0),
      }
    )
  ),

  -- switch
  s(
    "switch",
    fmt(
      [[
switch {} {{
case {}:
  {}
case {}:
  {}
default:
  {}
}}
]],
      {
        i(1, "value"),
        i(2),
        i(3),
        i(4),
        i(5),
        i(0),
      }
    )
  ),

  -- defer
  s(
    "defer",
    fmt(
      [[
defer {{
  {}
}}
]],
      {
        i(0),
      }
    )
  ),

  -- when (compile-time if)
  s(
    "when",
    fmt(
      [[
when {} {{
  {}
}}
]],
      {
        i(1, "ODIN_OS == .Windows"),
        i(0),
      }
    )
  ),

  -- import
  s(
    "import",
    fmt([[import "{}"]], {
      i(1, "core:fmt"),
    })
  ),
}
