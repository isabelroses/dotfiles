local wezterm = require("wezterm")
local utils = require("utils")

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- theme
require("catppuccin").apply_to_config(config)
require("bar").apply_to_config(config)

if utils.is_linux() then
  config.window_background_opacity = 0.90
elseif utils.is_darwin() then
  config.window_background_opacity = 0.95
elseif utils.is_windows() then
  config.window_background_image = "C:\\Users\\Isabel\\Pictures\\wallpapers\\wallhaven-qzp8dr.png"
  config.window_background_image_hsb = {
    brightness = 0.03, -- make the bg darker so we can see what we are doing
  }
end

-- shell
-- fix windows stuff
if utils.is_linux() then
  config.default_prog = { "fish", "-l" }
elseif utils.is_darwin() then
  config.default_prog = { "/etc/profiles/per-user/isabel/bin/fish", "-l" }
elseif utils.is_windows() then
  config.launch_menu = {
    {
      label = "PowerShell",
      args = { "pwsh.exe" },
    },
    {
      label = "WSL",
      args = { "wsl.exe" },
    },
  }
end

-- window stuff
config.window_decorations = "RESIZE"
config.window_padding = { left = 10, right = 0, top = 0, bottom = 0 }
config.adjust_window_size_when_changing_font_size = false

-- fonts
config.font = wezterm.font_with_fallback({
  "RobotoMono Nerd Font",
  "Symbols Nerd Font",
})
config.font_size = 13
config.adjust_window_size_when_changing_font_size = false

-- QOL
config.audible_bell = "Disabled"
config.default_cursor_style = "BlinkingBar"
config.front_end = "WebGpu"
config.window_close_confirmation = "NeverPrompt"
config.prefer_to_spawn_tabs = true

return config
