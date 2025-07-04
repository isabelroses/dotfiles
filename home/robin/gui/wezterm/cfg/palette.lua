local wezterm = require("wezterm")

local M = {}

local colors = {
  winter = {
    red = "#F57F82",
    orange = "#F7A182",
    yellow = "#F5D098",
    lime = "#DBE6AF",
    green = "#CBE3B3",
    aqua = "#B3E3CA",
    skye = "#B3E6DB",
    snow = "#AFD9E6",
    blue = "#B2CAED",
    purple = "#D2BDF3",
    pink = "#F3C0E5",
    cherry = "#F6CEE5",
    text = "#F8F9E8",
    subtext1 = "#ADC9BC",
    subtext0 = "#96B4AA",
    overlay2 = "#839E9A",
    overlay1 = "#6F8788",
    overlay0 = "#58686D",
    surface2 = "#4A585C",
    surface1 = "#374145",
    surface0 = "#262F33",
    base = "#1E2528",
    mantle = "#191E21",
    crust = "#171C1F",
  },
  fall = {
    red = "#F57F82",
    orange = "#F7A182",
    yellow = "#F5D098",
    lime = "#DBE6AF",
    green = "#CBE3B3",
    aqua = "#B3E3CA",
    skye = "#B3E6DB",
    snow = "#AFD9E6",
    blue = "#B2CAED",
    purple = "#D2BDF3",
    pink = "#F3C0E5",
    cherry = "#F6CEE5",
    text = "#F8F9E8",
    subtext1 = "#ADC9BC",
    subtext0 = "#96B4AA",
    overlay2 = "#839E9A",
    overlay1 = "#6F8788",
    overlay0 = "#58686D",
    surface2 = "#4A585C",
    surface1 = "#374145",
    surface0 = "#2B3337",
    base = "#232A2E",
    mantle = "#1C2225",
    crust = "#171C1F",
  },
  spring = {
    red = "#F57F82",
    orange = "#F7A182",
    yellow = "#F5D098",
    lime = "#DBE6AF",
    green = "#CBE3B3",
    aqua = "#B3E3CA",
    skye = "#B3E6DB",
    snow = "#AFD9E6",
    blue = "#B2CAED",
    purple = "#D2BDF3",
    pink = "#F3C0E5",
    cherry = "#F6CEE5",
    text = "#F8F9E8",
    subtext1 = "#ADC9BC",
    subtext0 = "#96B4AA",
    overlay2 = "#839E9A",
    overlay1 = "#6F8788",
    overlay0 = "#58686D",
    surface2 = "#4A585C",
    surface1 = "#3E4A4F",
    surface0 = "#343E43",
    base = "#2B3438",
    mantle = "#232A2E",
    crust = "#1C2225",
  },
  summer = {
    red = "#C0696B",
    orange = "#C1866B",
    yellow = "#BC9C6B",
    lime = "#A7AF70",
    green = "#91AC75",
    aqua = "#7BAA92",
    skye = "#79A39B",
    snow = "#7FA0AA",
    blue = "#8CA0BB",
    purple = "#AB9AC6",
    pink = "#CA9EBD",
    cherry = "#CEABBF",
    text = "#171C1F",
    subtext1 = "#415055",
    subtext0 = "#526469",
    overlay2 = "#63787D",
    overlay1 = "#758A90",
    overlay0 = "#879DA4",
    surface2 = "#9CB2B8",
    surface1 = "#B4C6CC",
    surface0 = "#CED9E0",
    base = "#D7E1EB",
    mantle = "#C8D5E1",
    crust = "#BDCBDB",
  },
}

local mappings = {
  winter = "Evergarden Winter",
  fall = "Evergarden Fall",
  spring = "Evergarden Spring",
  summer = "Evergarden Summer",
}

function M.get_palettes()
  return pairs(mappings)
end

function M.select(palette, flavor, accent)
  local c = palette[flavor]
  -- shorthand to check for the Latte flavor
  local isLight = palette == "latte"

  local cursor = c.pink
  return {
    foreground = c.text,
    background = c.base,

    cursor_fg = isLight and c.base or c.crust,
    cursor_bg = cursor,
    cursor_border = cursor,

    selection_fg = c.text,
    selection_bg = c.surface2,

    scrollbar_thumb = c.surface2,

    split = c.overlay0,

    ansi = {
      c.base,
      c.red,
      c.green,
      c.yellow,
      c.blue,
      c.pink,
      c.aqua,
      c.text,
    },

    brights = {
      c.overlay1,
      c.red,
      c.green,
      c.yellow,
      c.blue,
      c.pink,
      c.aqua,
      c.subtext0,
    },

    indexed = { [16] = c.peach, [17] = c.rosewater },

    -- nightbuild only
    compose_cursor = c.text,

    tab_bar = {
      background = c.mantle,
      active_tab = {
        bg_color = c[accent],
        fg_color = c.crust,
      },
      inactive_tab = {
        bg_color = c.surface0,
        fg_color = c.overlay1,
      },
      inactive_tab_hover = {
        bg_color = c.surface1,
        fg_color = c.overlay1,
      },
      new_tab = {
        bg_color = c.base,
        fg_color = c.overlay2,
      },
      new_tab_hover = {
        bg_color = c.surface0,
        fg_color = c.subtext0,
      },
      -- fancy tab bar
      inactive_tab_edge = c.surface0,
    },

    visual_bell = c.surface0,
  }
end

local function select_for_appearance(appearance, options)
  if appearance:find("Dark") then
    return options.dark
  else
    return options.light
  end
end

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

function M.apply_to_config(c, opts)
  opts = opts or {}

  -- default options
  local defaults = {
    flavor = "fall",
    accent = "green",
    sync = false,
    sync_flavors = { light = "summer", dark = "fall" },
    color_overrides = {
      fall = {},
    },
    token_overrides = {
      fall = {},
    },
  }

  local o = tableMerge(defaults, opts)

  -- insert all flavors
  local color_schemes = {}
  local palette = tableMerge(colors, o.color_overrides)
  for flavor, name in pairs(mappings) do
    local spec = M.select(palette, flavor, o.accent)
    local overrides = o.token_overrides[flavor] or {}
    color_schemes[name] = tableMerge(spec, overrides)
  end
  c.color_schemes = tableMerge(c.color_schemes or {}, color_schemes)

  if opts.sync then
    c.color_scheme = select_for_appearance(wezterm.gui.get_appearance(), {
      dark = mappings[o.sync_flavors.dark],
      light = mappings[o.sync_flavors.light],
    })
    c.command_palette_bg_color = select_for_appearance(wezterm.gui.get_appearance(), {
      dark = colors[o.sync_flavors.dark].crust,
      light = colors[o.sync_flavors.light].crust,
    })
    c.command_palette_fg_color = select_for_appearance(wezterm.gui.get_appearance(), {
      dark = colors[o.sync_flavors.dark].text,
      light = colors[o.sync_flavors.light].text,
    })
  else
    c.color_scheme = mappings[o.flavor]
    c.command_palette_bg_color = colors[o.flavor].crust
    c.command_palette_fg_color = colors[o.flavor].text
  end

  local window_frame = {
    active_titlebar_bg = colors[o.flavor].crust,
    active_titlebar_fg = colors[o.flavor].text,
    inactive_titlebar_bg = colors[o.flavor].crust,
    inactive_titlebar_fg = colors[o.flavor].text,
    button_fg = colors[o.flavor].text,
    button_bg = colors[o.flavor].base,
  }

  c.window_frame = tableMerge(c.window_frame or {}, window_frame)
end

return M
