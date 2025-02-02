-- https://github.com/nekowinston/wezterm-bar
local wezterm = require("wezterm")

local M = {}

-- default configuration
local config = {
  position = "top", -- or "bottom"
  max_width = 32,
  dividers = "slant_right", -- "slant_right" or "slant_left", "arrows", "rounded", false
  indicator = {
    leader = {
      enabled = true,
      off = " ",
      on = " ",
    },
    mode = {
      enabled = true,
      names = {
        resize_mode = "RESIZE",
        copy_mode = "VISUAL",
        search_mode = "SEARCH",
      },
    },
  },
  tabs = {
    numerals = "arabic", -- or "roman"
    pane_count = "superscript", -- or "subscript", false
    brackets = {
      active = { "", ":" },
      inactive = { "", ":" },
    },
  },
  clock = {
    enabled = false,
    format = "%I:%M %P", -- https://docs.rs/chrono/latest/chrono/format/strftime/index.html
  },
}

-- parsed config
local C = {}

local function tableMerge(t1, t2)
  for k, v in pairs(t2) do
    if type(v) == "table" then
      if type(t1[k] or false) == "table" then
        tableMerge(t1[k] or {}, t2[k] or {})
      else
        t1[k] = v
      end
    else
      t1[k] = v
    end
  end
  return t1
end

local dividers = {
  slant_right = {
    left = utf8.char(0xe0be),
    right = utf8.char(0xe0bc),
  },
  slant_left = {
    left = utf8.char(0xe0bb),
    right = utf8.char(0xe0b8),
  },
  arrows = {
    left = utf8.char(0xe0b2),
    right = utf8.char(0xe0b0),
  },
  rounded = {
    left = utf8.char(0xe0b6),
    right = utf8.char(0xe0b4),
  },
}

-- conforming to https://github.com/wez/wezterm/commit/e4ae8a844d8feaa43e1de34c5cc8b4f07ce525dd
-- exporting an apply_to_config function, even though we don't change the users config
M.apply_to_config = function(c, opts)
  -- make the opts arg optional
  if not opts then
    opts = {}
  end

  -- combine user config with defaults
  config = tableMerge(config, opts)
  C.div = {
    l = "",
    r = "",
  }

  if config.dividers then
    C.div.l = dividers[config.dividers].left
    C.div.r = dividers[config.dividers].right
  end

  C.leader = {
    enabled = config.indicator.leader.enabled and true,
    off = config.indicator.leader.off,
    on = config.indicator.leader.on,
  }

  C.mode = {
    enabled = config.indicator.mode.enabled,
    names = config.indicator.mode.names,
  }

  C.tabs = {
    numerals = config.tabs.numerals,
    pane_count_style = config.tabs.pane_count,
    brackets = {
      active = config.tabs.brackets.active,
      inactive = config.tabs.brackets.inactive,
    },
  }

  C.clock = {
    enabled = config.clock.enabled,
    format = config.clock.format,
  }

  -- set the right-hand padding to 0 spaces, if the rounded style is active
  C.p = (config.dividers == "rounded") and "" or " "

  -- set wezterm config options according to the parsed config
  c.use_fancy_tab_bar = false
  c.tab_bar_at_bottom = config.position == "bottom"
  c.tab_max_width = config.max_width
end

-- superscript/subscript
local function numberStyle(number, script)
  local scripts = {
    superscript = {
      "⁰",
      "¹",
      "²",
      "³",
      "⁴",
      "⁵",
      "⁶",
      "⁷",
      "⁸",
      "⁹",
    },
    subscript = {
      "₀",
      "₁",
      "₂",
      "₃",
      "₄",
      "₅",
      "₆",
      "₇",
      "₈",
      "₉",
    },
  }
  local numbers = scripts[script]
  local number_string = tostring(number)
  local result = ""
  for i = 1, #number_string do
    local char = number_string:sub(i, i)
    local num = tonumber(char)
    if num then
      result = result .. numbers[num + 1]
    else
      result = result .. char
    end
  end
  return result
end

local roman_numerals = {
  "Ⅰ",
  "Ⅱ",
  "Ⅲ",
  "Ⅳ",
  "Ⅴ",
  "Ⅵ",
  "Ⅶ",
  "Ⅷ",
  "Ⅸ",
  "Ⅹ",
  "Ⅺ",
  "Ⅻ",
}

local get_rainbow = function(conf)
  return {
    conf.resolved_palette.ansi[3],
    conf.resolved_palette.ansi[4],
    conf.resolved_palette.indexed[16],
    conf.resolved_palette.ansi[2],
    conf.resolved_palette.ansi[6],
    conf.resolved_palette.ansi[5],
  }
end

-- custom tab bar
wezterm.on("format-tab-title", function(tab, tabs, _panes, conf, _hover, _max_width)
  local colours = conf.resolved_palette.tab_bar

  local active_tab_index = 0
  for _, t in ipairs(tabs) do
    if t.is_active == true then
      active_tab_index = t.tab_index
    end
  end

  local rainbow = get_rainbow(conf)

  local i = tab.tab_index % 6
  local active_bg = rainbow[i + 1]
  local active_fg = colours.background
  local inactive_bg = colours.inactive_tab.bg_color
  local inactive_fg = colours.inactive_tab.fg_color
  local new_tab_bg = colours.new_tab.bg_color

  local s_bg, s_fg, e_bg, e_fg

  -- the last tab
  if tab.tab_index == #tabs - 1 then
    if tab.is_active then
      s_bg = active_bg
      s_fg = active_fg
      e_bg = new_tab_bg
      e_fg = active_bg
    else
      s_bg = inactive_bg
      s_fg = inactive_fg
      e_bg = new_tab_bg
      e_fg = inactive_bg
    end
  elseif tab.tab_index == active_tab_index - 1 then
    s_bg = inactive_bg
    s_fg = inactive_fg
    e_bg = rainbow[(i + 1) % 6 + 1]
    e_fg = inactive_bg
  elseif tab.is_active then
    s_bg = active_bg
    s_fg = active_fg
    e_bg = inactive_bg
    e_fg = active_bg
  else
    s_bg = inactive_bg
    s_fg = inactive_fg
    e_bg = inactive_bg
    e_fg = inactive_bg
  end

  local pane_count = ""
  if C.tabs.pane_count_style then
    local tabi = wezterm.mux.get_tab(tab.tab_id)
    local muxpanes = tabi:panes()
    local count = #muxpanes == 1 and "" or tostring(#muxpanes)
    pane_count = numberStyle(count, C.tabs.pane_count_style)
  end

  local index_i
  if C.tabs.numerals == "roman" then
    index_i = roman_numerals[tab.tab_index + 1]
  else
    index_i = tab.tab_index + 1
  end

  local index
  if tab.is_active then
    index = string.format("%s%s%s ", C.tabs.brackets.active[1], index_i, C.tabs.brackets.active[2])
  else
    index = string.format("%s%s%s ", C.tabs.brackets.inactive[1], index_i, C.tabs.brackets.inactive[2])
  end

  -- start and end hardcoded numbers are the Powerline + " " padding
  local fillerwidth = 2 + string.len(index) + string.len(pane_count) + 2

  -- prefer renamed table titles to the default title
  local tabtitle = tab.tab_title
  if #tabtitle <= 0 then
    tabtitle = tab.active_pane.title
  end

  local width = conf.tab_max_width - fillerwidth - 1
  if (#tabtitle + fillerwidth) > conf.tab_max_width then
    tabtitle = wezterm.truncate_right(tabtitle, width) .. "…"
  end

  local title = string.format(" %s%s%s%s", index, tabtitle, pane_count, C.p)

  return {
    { Background = { Color = s_bg } },
    { Foreground = { Color = s_fg } },
    { Text = title },
    { Background = { Color = e_bg } },
    { Foreground = { Color = e_fg } },
    { Text = C.div.r },
  }
end)

wezterm.on("update-status", function(window, _pane)
  local active_kt = window:active_key_table() ~= nil
  local show = C.leader.enabled or (active_kt and C.mode.enabled)
  if not show then
    window:set_left_status("")
    return
  end

  local present, conf = pcall(window.effective_config, window)
  if not present then
    return
  end

  local palette = conf.resolved_palette
  local rainbow = get_rainbow(conf)

  local leader = ""
  if C.leader.enabled then
    local leader_text = C.leader.off
    if window:leader_is_active() then
      leader_text = C.leader.on
    end
    leader = wezterm.format({
      { Foreground = { Color = palette.background } },
      { Background = { Color = rainbow[1] } },
      { Text = " " .. leader_text .. C.p },
    })
  end

  local mode = ""
  if C.mode.enabled then
    local mode_text = ""
    local active = window:active_key_table()
    if C.mode.names[active] ~= nil then
      mode_text = C.mode.names[active] .. ""
    end
    mode = wezterm.format({
      { Foreground = { Color = palette.background } },
      { Background = { Color = palette.ansi[5] } },
      { Attribute = { Intensity = "Bold" } },
      { Text = mode_text },
      "ResetAttributes",
    })
  end

  local first_tab_active = window:mux_window():tabs_with_info()[1].is_active
  local divider_bg = first_tab_active and rainbow[1] or palette.tab_bar.inactive_tab.bg_color

  local divider = wezterm.format({
    { Background = { Color = divider_bg } },
    { Foreground = { Color = palette.ansi[3] } },
    { Text = C.div.r },
  })

  window:set_left_status(leader .. mode .. divider)

  if C.clock.enabled then
    local time = wezterm.time.now():format(C.clock.format)
    window:set_right_status(wezterm.format({
      { Background = { Color = palette.tab_bar.background } },
      { Foreground = { Color = palette.ansi[6] } },
      { Text = time },
    }))
  end
end)

return M
