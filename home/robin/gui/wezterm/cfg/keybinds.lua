local wezterm = require("wezterm")
local act = wezterm.action

local utils = require("utils")

local M = {}

local openUrl = act.QuickSelectArgs({
  label = "open url",
  patterns = { "https?://\\S+" },
  action = wezterm.action_callback(function(window, pane)
    local url = window:get_selection_text_for_pane(pane)
    wezterm.open_with(url)
  end),
})

local palettes = {}
for id, name in require("palette").get_palettes() do
  palettes[#palettes + 1] = { label = name, id = id }
end

local changePalette = act.InputSelector({
  title = "Change palette",
  choices = { { label = "Evergarden Winter" } },
  fuzzy = true,
  action = wezterm.action_callback(function(window, _, id, label)
    if not label then
      return
    end
    window:set_config_overrides({ color_scheme = label })
  end),
})

local getNewName = act.PromptInputLine({
  description = "Enter new name for tab",
  action = wezterm.action_callback(function(window, pane, line)
    if not line then
      return
    end
    window:active_tab():set_title(line)
  end),
})

local keys = {}
local map = function(key, mods, action)
  if type(mods) == "string" then
    table.insert(keys, { key = key, mods = mods, action = action })
  elseif type(mods) == "table" then
    for _, mod in pairs(mods) do
      table.insert(keys, { key = key, mods = mod, action = action })
    end
  end
end

map("Enter", "ALT", act.ToggleFullScreen)

map("e", "CTRL|SHIFT", getNewName)
map("o", { "LEADER", "SUPER" }, openUrl)
map("t", "ALT", changePalette)

M.apply = function(c)
  c.leader = {
    key = "m",
    mods = "ALT",
    timeout_milliseconds = 300,
  }
  c.keys = keys
  -- c.disable_default_key_bindings = true
end

return M
