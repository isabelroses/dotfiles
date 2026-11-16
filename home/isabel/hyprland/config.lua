local mod = "SUPER"

hl.config({
  general = {
    gaps_in = 0,
    gaps_out = 0,
    col = {
      active_border = colors.accent,
      inactive_border = colors.surface1,
    },
  },

  decoration = {
    rounding = 0,
    blur = {
      contrast = 1.3,
      passes = 2,
      size = 2,
      variant = "frost",
      xray = true,
    },
    shadow = {
      color = "rgb(11111B)",
      color_inactive = "rgba(11111B00)",
    },
  },

  render = {
    cm_auto_hdr = false,
  },

  dwindle = {
    preserve_split = true,
  },

  group = {
    col = {
      border_active = colors.rosewater,
      border_inactive = colors.surface1,
    },
    groupbar = {
      font_size = 12,
      render_titles = false,
    },
  },

  input = {
    kb_layout = kb,
    numlock_by_default = true,
    sensitivity = (kb == "us") and -0.8 or 0,
    touchpad = {
      disable_while_typing = false,
    },
  },

  misc = {
    disable_autoreload = true,
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    enable_anr_dialog = false,
    force_default_wallpaper = 0,
    key_press_enables_dpms = true,
    mouse_move_enables_dpms = true,
  },
})

-- Monitors
for _, m in ipairs(monitors) do
  hl.monitor({
    output = m.output,
    mode = m.mode,
    position = m.position,
    scale = m.scale,
  })
end

-- Split workspaces 1-10 into contiguous blocks per monitor; the last takes the remainder
if #monitors > 1 then
  local per_mon = math.floor(10 / #monitors)
  for ws = 1, 10 do
    local idx = math.min(math.floor((ws - 1) / per_mon), #monitors - 1)
    hl.workspace_rule({
      workspace = ws,
      monitor = monitors[idx + 1].output,
      default = ws == idx * per_mon + 1 or nil,
    })
  end
end

-- Animations
hl.curve("wind", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("winIn", { type = "bezier", points = { { 0.1, 1.1 }, { 0.1, 1.1 } } })
hl.curve("winOut", { type = "bezier", points = { { 0.3, -0.3 }, { 0, 1 } } })
hl.curve("liner", { type = "bezier", points = { { 1, 1 }, { 1, 1 } } })
hl.curve("easeOut", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, bezier = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "wind", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "liner" })
hl.animation({ leaf = "fade", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "easeOut" })

-- Gestures
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })

-- Layer rules
hl.layer_rule({ match = { namespace = "vicinae" }, blur = true, ignore_alpha = 0, no_anim = true })
hl.layer_rule({ match = { namespace = "quicksettings|settings" }, no_anim = true })

-- Window rules (patterns must match the whole string)
local floating = {
  { title = "nm-connection-editor" },
  { title = "Network" },
  { title = "xdg-desktop-portal-gtk" },
  { title = "Picture-in-Picture" },
  { title = "(?i).*bitwarden.*", size = "800 600" },
  { class = "gay\\.vaskel\\.soteria" },
  { class = "download" },
  { initial_title = "Open Files", dialog = true },
  { class = "\\.blueman-manager-wrapped", dialog = true },
  { class = "com\\.saivert\\.pwvucontrol", dialog = true },
}
for _, w in ipairs(floating) do
  hl.window_rule({
    match = { title = w.title, class = w.class, initial_title = w.initial_title },
    float = true,
    center = w.dialog or nil,
    size = w.dialog and "(monitor_w*0.4) (monitor_h*0.6)" or w.size,
  })
end

local app_workspaces = {
  -- class,                      2 monitors, otherwise
  { "(?i)chromium(-browser)?",   1, 2 },
  { "(?i)discord",               2, 6 },
  { "com\\.mitchellh\\.ghostty", 6, 1 },
  { "(?i)spotify",               7, 7 },
  { "(?i)signal",                8, 8 },
}
for _, app in ipairs(app_workspaces) do
  local ws = #monitors == 2 and app[2] or app[3]
  hl.window_rule({ match = { class = app[1] }, workspace = tostring(ws) })
end

-- Screen-share indicators
hl.window_rule({ match = { title = "Firefox — Sharing Indicator" }, workspace = "special silent" })
hl.window_rule({ match = { title = ".*is sharing (your screen|a window)\\." }, workspace = "special silent" })

-- Apps
hl.bind(mod .. " + D", hl.dsp.exec_cmd("vicinae toggle"))
hl.bind(mod .. " + B", hl.dsp.exec_cmd("chromium"))
hl.bind(mod .. " + E", hl.dsp.exec_cmd("cosmic-files"))
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + L", hl.dsp.exec_cmd("qs ipc call shell lock"))
hl.bind(mod .. " + O", hl.dsp.exec_cmd("obsidian"))
hl.bind(mod .. " + SHIFT + V", hl.dsp.exec_cmd("vicinae deeplink vicinae://launch/clipboard/history"))

-- Windows
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd("qs ipc call screenshot menu"))
hl.bind("ALT + SHIFT + S", hl.dsp.exec_cmd("qs ipc call screenshot menu"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("qs ipc call screenshot region"))

-- Media keys, usable on the lock screen
local media = {
  { "XF86AudioMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" },
  { "XF86AudioMicMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" },
  { "XF86AudioPlay", "playerctl play-pause" },
  { "XF86AudioPause", "playerctl play-pause" },
  { "XF86AudioNext", "playerctl next" },
  { "XF86AudioPrev", "playerctl previous" },
  { "XF86AudioRaiseVolume", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+", true },
  { "XF86AudioLowerVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", true },
  { "XF86MonBrightnessUp", "qs ipc call brightness up", true },
  { "XF86MonBrightnessDown", "qs ipc call brightness down", true },
}
for _, k in ipairs(media) do
  hl.bind(k[1], hl.dsp.exec_cmd(k[2]), { locked = true, repeating = k[3] })
end

-- Workspaces
for i = 1, 10 do
  local key = i % 10
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + grave", hl.dsp.workspace.toggle_special())
hl.bind(mod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special" }))

-- Move / resize submaps; arrows or ijkl
local directions = {
  { keys = { "left", "j" }, dir = "l", x = -20, y = 0 },
  { keys = { "right", "l" }, dir = "r", x = 20, y = 0 },
  { keys = { "up", "i" }, dir = "u", x = 0, y = -20 },
  { keys = { "down", "k" }, dir = "d", x = 0, y = 20 },
}

hl.bind(mod .. " + M", hl.dsp.submap("move"))
hl.define_submap("move", function()
  for _, d in ipairs(directions) do
    for _, key in ipairs(d.keys) do
      hl.bind(key, hl.dsp.window.move({ direction = d.dir }), { repeating = true })
    end
  end
  hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.bind(mod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
  for _, d in ipairs(directions) do
    for _, key in ipairs(d.keys) do
      hl.bind(key, hl.dsp.window.resize({ x = d.x, y = d.y, relative = true }), { repeating = true })
    end
  end
  hl.bind("escape", hl.dsp.submap("reset"))
end)
