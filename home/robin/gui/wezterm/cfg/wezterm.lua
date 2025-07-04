local utils = require("utils")
local wezterm = require("wezterm")

local c = {}
if wezterm.c_builder then
  c = wezterm.config_builder()
end

c.enable_wayland = true

-- theme
require("palette").apply_to_config(c, {
  flavor = "winter",
  accent = "skye",
})
require("bar").apply_to_config(c, {
  dividers = "rounded",
})

if utils.is_linux() then
  c.window_background_opacity = 0.92
elseif utils.is_darwin() then
  c.window_background_opacity = 0.92
  c.macos_window_background_blur = 15
elseif utils.is_windows() then
  -- c.window_background_image = ""
  -- c.window_background_image_hsb = {
  -- 	brightness = 0.03, -- make the bg darker so we can see what we are doing
  -- }
  -- c.win32_system_backdrop = "Tabbed"
  -- c.window_background_opacity = 0.95
  -- c.background = {
  --   {
  --     source = {
  --       File = "D:\\pictures\\wallpapers\\frieren\\wallhaven-l87gvr.jpg",
  --     },
  --     hsb = {
  --       brightness = 0.05,
  --       saturation = 1.02,
  --     },
  --   }
  -- }
  c.window_background_opacity = 0.92
  c.win32_system_backdrop = "Mica"
end

-- load my keybinds
require("keybinds").apply(c)

-- default shell
if utils.is_linux() or utils.is_darwin() then
  c.default_prog = { "/etc/profiles/per-user/robin/bin/zsh", "--login" }
elseif utils.is_windows() then
  c.default_prog = { "wsl.exe" }
  c.default_domain = "WSL:NixOS"
  c.launch_menu = {
    {
      label = "PowerShell",
      args = { "pwsh.exe", "-NoLogo" },
      domain = { DomainName = "local" },
    },
    {
      label = "WSL",
      args = { "wsl.exe" },
      domain = { DomainName = "WSL:NixOS" },
    },
  }
end

if utils.is_linux() then
  c.window_decorations = "TITLE | RESIZE"
else
  c.window_decorations = "RESIZE"
end

c.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

-- fonts
local font = wezterm.font_with_fallback({
  {
    family = "Maple Mono",
    harfbuzz_features = {
      "zero",
      "cv01", -- `@ $ & % Q => ->` without gap

      -- consistent style
      -- "cv33", -- italic `i` j with left bottom bar and horizen top bar, just like regular style

      -- no tails
      "cv34", -- italic `k` without circle, just like regular style
      "cv35", -- italic `l` without tail, just like regular style
      -- "cv36", -- italic `x` without tails, just like regular style
      -- "ss06", -- Break connected strokes between italic letters (al, ul, il ...)

      -- disable ligatures
      "ss01", -- Broken equals ligatures (==, ===, !=, !==, =/=)
      "ss02", -- Broken compare and equal ligatures (<=, >=)
      "ss04", -- Break multiple underscores (__, #__)

      "ss03", -- Enable arbitrary tag (allow to use any case in all tags)

      "ss05", -- Thin backslash in escape letters (\w, \n, \r ...)

      "ss07", -- Relax the conditions for multiple greaters ligatures (>> or >>>)
      -- "ss08", -- Enable double headed arrows and reverse arrows (>>=, -<<, ->>, >- ...)
    },
  },
  { family = "Symbols Nerd Font" },
})
c.font = font
c.font_size = 12
c.allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace"
c.freetype_load_target = "Light"
c.freetype_load_flags = "FORCE_AUTOHINT"
c.adjust_window_size_when_changing_font_size = false
c.window_frame = {
  font = font,
  font_size = c.font_size,
}
c.line_height = 1.1

-- QOL
c.audible_bell = "Disabled"
c.default_cursor_style = "BlinkingBar"
c.window_close_confirmation = "NeverPrompt"
-- c.prefer_to_spawn_tabs = true

if utils.is_windows() then
  c.front_end = "OpenGL"
else
  c.front_end = "WebGpu"
end

-- this is nix so lets not do it
-- enable this if i ever setup nix to statically link
c.check_for_updates = false

return c
