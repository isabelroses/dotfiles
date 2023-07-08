let catppuccin = {
  latte: {
    rosewater: "#dc8a78"
    flamingo: "#dd7878"
    pink: "#ea76cb"
    mauve: "#8839ef"
    red: "#d20f39"
    maroon: "#e64553"
    peach: "#fe640b"
    yellow: "#df8e1d"
    green: "#40a02b"
    teal: "#179299"
    sky: "#04a5e5"
    sapphire: "#209fb5"
    blue: "#1e66f5"
    lavender: "#7287fd"
    text: "#4c4f69"
    subtext1: "#5c5f77"
    subtext0: "#6c6f85"
    overlay2: "#7c7f93"
    overlay1: "#8c8fa1"
    overlay0: "#9ca0b0"
    surface2: "#acb0be"
    surface1: "#bcc0cc"
    surface0: "#ccd0da"
    crust: "#dce0e8"
    mantle: "#e6e9ef"
    base: "#eff1f5"
  }
  frappe: {
    rosewater: "#f2d5cf"
    flamingo: "#eebebe"
    pink: "#f4b8e4"
    mauve: "#ca9ee6"
    red: "#e78284"
    maroon: "#ea999c"
    peach: "#ef9f76"
    yellow: "#e5c890"
    green: "#a6d189"
    teal: "#81c8be"
    sky: "#99d1db"
    sapphire: "#85c1dc"
    blue: "#8caaee"
    lavender: "#babbf1"
    text: "#c6d0f5"
    subtext1: "#b5bfe2"
    subtext0: "#a5adce"
    overlay2: "#949cbb"
    overlay1: "#838ba7"
    overlay0: "#737994"
    surface2: "#626880"
    surface1: "#51576d"
    surface0: "#414559"
    base: "#303446"
    mantle: "#292c3c"
    crust: "#232634"
  }
  macchiato: {
    rosewater: "#f4dbd6"
    flamingo: "#f0c6c6"
    pink: "#f5bde6"
    mauve: "#c6a0f6"
    red: "#ed8796"
    maroon: "#ee99a0"
    peach: "#f5a97f"
    yellow: "#eed49f"
    green: "#a6da95"
    teal: "#8bd5ca"
    sky: "#91d7e3"
    sapphire: "#7dc4e4"
    blue: "#8aadf4"
    lavender: "#b7bdf8"
    text: "#cad3f5"
    subtext1: "#b8c0e0"
    subtext0: "#a5adcb"
    overlay2: "#939ab7"
    overlay1: "#8087a2"
    overlay0: "#6e738d"
    surface2: "#5b6078"
    surface1: "#494d64"
    surface0: "#363a4f"
    base: "#24273a"
    mantle: "#1e2030"
    crust: "#181926"
  }
  mocha: {
    rosewater: "#f5e0dc"
    flamingo: "#f2cdcd"
    pink: "#f5c2e7"
    mauve: "#cba6f7"
    red: "#f38ba8"
    maroon: "#eba0ac"
    peach: "#fab387"
    yellow: "#f9e2af"
    green: "#a6e3a1"
    teal: "#94e2d5"
    sky: "#89dceb"
    sapphire: "#74c7ec"
    blue: "#89b4fa"
    lavender: "#b4befe"
    text: "#cdd6f4"
    subtext1: "#bac2de"
    subtext0: "#a6adc8"
    overlay2: "#9399b2"
    overlay1: "#7f849c"
    overlay0: "#6c7086"
    surface2: "#585b70"
    surface1: "#45475a"
    surface0: "#313244"
    base: "#1e1e2e"
    mantle: "#181825"
    crust: "#11111b"
  }
}

let stheme = $catppuccin.mocha

let theme = {
  separator: $stheme.overlay0
  leading_trailing_space_bg: $stheme.overlay0
  header: $stheme.green
  date: $stheme.mauve
  filesize: $stheme.blue
  row_index: $stheme.pink
  bool: $stheme.peach
  int: $stheme.peach
  duration: $stheme.peach
  range: $stheme.peach
  float: $stheme.peach
  string: $stheme.green
  nothing: $stheme.peach
  binary: $stheme.peach
  cellpath: $stheme.peach
  hints: dark_gray

  shape_garbage: { fg: $stheme.crust bg: $stheme.red attr: b }
  shape_bool: $stheme.blue
  shape_int: { fg: $stheme.mauve attr: b}
  shape_float: { fg: $stheme.mauve attr: b}
  shape_range: { fg: $stheme.yellow attr: b}
  shape_internalcall: { fg: $stheme.blue attr: b}
  shape_external: { fg: $stheme.blue attr: b}
  shape_externalarg: $stheme.text 
  shape_literal: $stheme.blue
  shape_operator: $stheme.yellow
  shape_signature: { fg: $stheme.green attr: b}
  shape_string: $stheme.green
  shape_filepath: $stheme.yellow
  shape_globpattern: { fg: $stheme.blue attr: b}
  shape_variable: $stheme.text
  shape_flag: { fg: $stheme.blue attr: b}
  shape_custom: {attr: b}
}

let-env config = {
  show_banner: false
  cursor_shape: {
    vi_normal: block
    vi_insert: line
  }
  edit_mode: vi
  render_right_prompt_on_last_line: true
  rm: {
    always_trash: true
  }
  color_config: $theme
  keybindings: [
    {
      name: completion_menu
      modifier: none
      keycode: tab
      mode: [emacs vi_normal vi_insert]
      event: {
        until: [
          { send: menu name: completion_menu }
          { send: menunext }
        ]
      }
    }
    {
      name: completion_previous
      modifier: shift
      keycode: backtab
      mode: [emacs, vi_normal, vi_insert] # Note: You can add the same keybinding to all modes by using a list
      event: { send: menuprevious }
    }
    {
      name: jump_to_start
      keycode: char_h
      modifier: shift
      mode: [vi_normal] 
      event: { edit: MoveToLineStart }
    }
    {
      name: jump_to_end
      modifier: shift
      keycode: char_l
      mode: [vi_normal] 
      event: { edit: MoveToLineEnd }
    }
  ]
  completions: {
    algorithm: "fuzzy"
  }
  hooks: {
    pre_prompt: [{ ||
      let direnv = (direnv export json | from json)
      let direnv = if ($direnv | length) == 1 { $direnv } else { {} }
      $direnv | load-env
    }]
    pre_execution: [{ || }]
  }
}

let-env PROMPT_INDICATOR_VI_INSERT = "I "
let-env PROMPT_INDICATOR_VI_NORMAL = "N "

# Aliases
# ls to exa
alias ls = exa -al --color=always --icons --group-directories-first
alias la = exa -a --color=always --icons --group-directories-firt
alias ll = exa -abghHliS --icons --group-directories-first
alias lt = exa -aT --color=always --icons --group-directories-first

alias df = df -h # human readblity
alias rs = sudo reboot
alias sysctl = sudo systemctl
alias doas = doas --
alias jctl = journalctl -p 3 -xb # get error messages from journalctl
alias lg = lazygit
alias ssp = ~/shells/spawnshell.sh


use "~/.config/nushell/scripts/custom-completions/nix/nix-completions.nu" *
use "~/.config/nushell/scripts/custom-completions/git/git-completions.nu" *
use "~/.config/nushell/scripts/custom-completions/npm/npm-completions.nu" *
use "~/.config/nushell/scripts/custom-completions/just/just-completions.nu" *
use "~/.config/nushell/scripts/custom-completions/tealdeer/tldr-completions.nu" *
use "~/.config/nushell/scripts/custom-completions/btm/btm-completions.nu" *
use "~/.config/nushell/scripts/custom-completions/make/make-completions.nu" *

source ~/.cache/starship/init.nu
