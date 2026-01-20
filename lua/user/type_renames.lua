local ts_utils = require "nvim-treesitter.ts_utils"

local M = {}

-- Extract identifiers with depth limiting
-- Map<String, List<Player>> -> { "Map", "String" }
local function extract_identifiers(type_text)
  local identifiers = {}

  local outer = type_text:match "^%s*([%w_]+)"
  if outer then table.insert(identifiers, outer) end

  local generic = type_text:match "<%s*([%w_]+)"
  if generic then table.insert(identifiers, generic) end

  return identifiers
end

local function build_name(parts)
  if #parts == 0 then return nil end

  local name = parts[1]:sub(1, 1):lower() .. parts[1]:sub(2)
  for i = 2, #parts do
    name = name .. parts[i]
  end
  return name
end

local function infer_name(type_text) return build_name(extract_identifiers(type_text)) end

function M.rename_params()
  local node = ts_utils.get_node_at_cursor()
  if not node then return end

  while node and node:type() ~= "method_declaration" do
    node = node:parent()
  end
  if not node then
    vim.notify("Not inside a method", vim.log.levels.WARN)
    return
  end

  local params
  for child in node:iter_children() do
    if child:type() == "formal_parameters" then
      params = child
      break
    end
  end
  if not params then return end

  local used_names = {}
  local param_nodes = {}

  for param in params:iter_children() do
    if param:type() ~= "formal_parameter" then goto continue end

    local type_node = param:field("type")[1]
    local name_node = param:field("name")[1]
    if not type_node or not name_node then goto continue end

    local old_name = vim.treesitter.get_node_text(name_node, 0)
    if not old_name:gmatch "^(arg|var)%d$" then goto continue end

    local type_text = vim.treesitter.get_node_text(type_node, 0)
    local base_name = infer_name(type_text)
    if not base_name then goto continue end

    local new_name = base_name
    local i = 2
    while used_names[new_name] do
      new_name = base_name .. i
      i = i + 1
    end

    used_names[new_name] = true
    table.insert(param_nodes, { name_node, new_name })
    ::continue::
  end
  for i = #param_nodes, 1, -1 do
    local node_pair = param_nodes[i]
    local old_name = vim.treesitter.get_node_text(node_pair[1], 0)
    local row, col = node_pair[1]:start()
    vim.api.nvim_buf_set_text(0, row, col, row, col + #old_name, { node_pair[2] })
  end
end

return M
