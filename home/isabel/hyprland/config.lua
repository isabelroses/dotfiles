local mod = "SUPER"

hl.config({
  general = {
    border_size = 2,
    gaps_in = 8,
    gaps_out = 8,
    gaps_workspaces = 0,
    col = {
      active_border = colors.accent,
      inactive_border = colors.surface1,
    },
  },

  decoration = {
    rounding = 15,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    fullscreen_opacity = 1.0,
    blur = {
      enabled = true,
      brightness = 1,
      contrast = 1.3,
      ignore_opacity = true,
      new_optimizations = true,
      noise = 0.0117,
      passes = 2,
      size = 2,
      xray = true,
    },
    shadow = {
      enabled = true,
      color = "rgb(11111B)",
      color_inactive = "rgba(11111B00)",
    },
  },

  dwindle = {
    preserve_split = true,
  },

  group = {
    focus_removed_window = true,
    insert_after_current = true,
    col = {
      border_active = colors.rosewater,
      border_inactive = colors.surface1,
    },
    groupbar = {
      font_size = 12,
      gradients = false,
      render_titles = false,
      scrolling = true,
    },
  },

  input = {
    kb_layout = kb,
    follow_mouse = 1,
    numlock_by_default = true,
    sensitivity = (kb == "us") and -0.8 or 0,
    touchpad = {
      disable_while_typing = false,
      natural_scroll = false,
      tap_to_click = true,
    },
  },

  misc = {
    disable_autoreload = true,
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    enable_anr_dialog = false,
    enable_swallow = false,
    force_default_wallpaper = 0,
    key_press_enables_dpms = true,
    mouse_move_enables_dpms = true,
    swallow_regex = "wezterm|foot|cosmic-files|nemo|com.mitchellh.ghostty",
  },

  cursor = {
    no_hardware_cursors = true,
  },

  animations = {
    enabled = true,
  },
})

-- Bezier curves
hl.curve("wind", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("winIn", { type = "bezier", points = { { 0.1, 1.1 }, { 0.1, 1.1 } } })
hl.curve("winOut", { type = "bezier", points = { { 0.3, -0.3 }, { 0, 1 } } })
hl.curve("liner", { type = "bezier", points = { { 1, 1 }, { 1, 1 } } })

-- Animations
hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "wind", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, bezier = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "wind", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "liner" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "liner", style = "loop" })
hl.animation({ leaf = "fade", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "wind" })

-- Gestures
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })

-- Layer rules
hl.layer_rule({ match = { namespace = "vicinae" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "vicinae" }, no_anim = true })

-- Window rules
hl.window_rule({ match = { title = "^(nm-connection-editor)$" }, float = true })
hl.window_rule({ match = { title = "^(Network)$" }, float = true })
hl.window_rule({ match = { title = "^(xdg-desktop-portal-gtk)$" }, float = true })
hl.window_rule({ match = { class = "gay.vaskel.soteria" }, float = true })
hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, float = true })
hl.window_rule({ match = { class = "^(download)$" }, float = true })

hl.window_rule({
  match = { initial_title = "(Open Files)" },
  center = true,
  float = true,
  size = "(monitor_w*0.4) (monitor_h*0.6)",
})
hl.window_rule({
  match = { class = ".blueman-manager-wrapped" },
  center = true,
  float = true,
  size = "(monitor_w*0.4) (monitor_h*0.6)",
})
hl.window_rule({
  match = { class = "com.saivert.pwvucontrol" },
  center = true,
  float = true,
  size = "(monitor_w*0.4) (monitor_h*0.6)",
})

hl.window_rule({ match = { title = "(?i)bitwarden" }, float = true, size = "800 600" })

hl.window_rule({ match = { class = "(?i)discord" }, workspace = "6" })
hl.window_rule({ match = { class = "(?i)spotify" }, workspace = "7" })
hl.window_rule({ match = { class = "(?i)signal" }, workspace = "8" })

hl.window_rule({ match = { title = "^(Firefox — Sharing Indicator)$" }, workspace = "special silent" })
hl.window_rule({ match = { title = "^(.*is sharing (your screen|a window).)$" }, workspace = "special silent" })

-- Keybindings
hl.bind(mod .. " + D", hl.dsp.exec_cmd("vicinae toggle"))
hl.bind(mod .. " + B", hl.dsp.exec_cmd("chromium"))
hl.bind(mod .. " + E", hl.dsp.exec_cmd("cosmic-files"))
hl.bind(mod .. " + C", hl.dsp.exec_cmd(editor))
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + L", hl.dsp.exec_cmd(screenLocker))
hl.bind(mod .. " + O", hl.dsp.exec_cmd("obsidian"))
hl.bind(mod .. " + SHIFT + V", hl.dsp.exec_cmd("vicinae deeplink vicinae://launch/clipboard/history"))

hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P", hl.dsp.window.pseudo())

hl.bind(mod .. " + grave", hl.dsp.workspace.toggle_special())
hl.bind(mod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special" }))

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

-- Audio / media keys
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

-- Repeating volume / brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+ -q"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%- -q"), { repeating = true })

-- Workspaces 1..10
for i = 1, 10 do
  local key = i % 10 -- 10 -> 0
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Workspace scroll
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Mouse drag / resize
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Submap: move
hl.bind(mod .. " + M", hl.dsp.submap("move"))
hl.define_submap("move", function()
  hl.bind("left", hl.dsp.window.move({ direction = "l" }), { repeating = true })
  hl.bind("right", hl.dsp.window.move({ direction = "r" }), { repeating = true })
  hl.bind("up", hl.dsp.window.move({ direction = "u" }), { repeating = true })
  hl.bind("down", hl.dsp.window.move({ direction = "d" }), { repeating = true })
  hl.bind("j", hl.dsp.window.move({ direction = "l" }), { repeating = true })
  hl.bind("l", hl.dsp.window.move({ direction = "r" }), { repeating = true })
  hl.bind("i", hl.dsp.window.move({ direction = "u" }), { repeating = true })
  hl.bind("k", hl.dsp.window.move({ direction = "d" }), { repeating = true })

  hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Submap: resize
hl.bind(mod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
  hl.bind("left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
  hl.bind("right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
  hl.bind("up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
  hl.bind("down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
  hl.bind("h", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
  hl.bind("j", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
  hl.bind("i", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
  hl.bind("k", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })

  hl.bind("escape", hl.dsp.submap("reset"))
end)
