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

local changeCtpFlavor = act.InputSelector({
  title = "Change Catppuccin flavor",
  choices = {
    { label = "Espresso" },
    { label = "Mocha" },
    { label = "Macchiato" },
    { label = "Frappe" },
    { label = "Latte" },
  },
  action = wezterm.action_callback(function(window, _, _, label)
    if label then
      window:set_config_overrides({ color_scheme = "Catppuccin " .. label })
    end
  end),
})

local getNewName = act.PromptInputLine({
  description = "Enter new name for tab",
  action = wezterm.action_callback(function(window, pane, line)
    if line then
      window:active_tab():set_title(line)
    end
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
map("t", "LEADER", changeCtpFlavor)

local leader

if utils.is_windows() then
  leader = "ALT"
else
  leader = " "
end

M.apply = function(c)
  c.leader = {
    key = leader,
    mods = "SUPER",
    timeout_milliseconds = math.maxinteger,
  }
  c.keys = keys
  -- c.disable_default_key_bindings = true
end

return M
