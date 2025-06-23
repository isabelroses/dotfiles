{
  lib,
  osClass,
  ...
}:
let
  inherit (lib) mkOption mapAttrs;
  inherit (lib.types) enum nullOr str;

  mkDefault = name: args: mkOption ({ description = "default ${name} for the system"; } // args);

in
{
  options.garden.programs.defaults = mapAttrs mkDefault {
    shell = {
      type = enum [
        "bash"
        "zsh"
        "fish"
        "nushell"
      ];
      default = if (osClass == "nixos") then "bash" else "zsh";
    };

    terminal = {
      type = enum [
        "ghostty"
        "alacritty"
        "ghostty"
        "kitty"
        "wezterm"
        "foot"
      ];
      default = "ghostty";
    };

    fileManager = {
      type = enum [
        "cosmic-files"
        "dolphin"
        "nemo"
      ];
      default = "cosmic-files";
    };

    browser = {
      type = enum [
        "firefox"
        "chromium"
        "thorium"
      ];
      default = "chromium";
    };

    editor = {
      type = enum [
        "nvim"
        "codium"
      ];
      default = "nvim";
    };

    pager = {
      type = str;
      default = "less -FR";
    };

    manpager = {
      type = str;
      default = "nvim +Man!";
    };

    launcher = {
      type = nullOr (enum [
        "rofi"
        "wofi"
        "cosmic-launcher"
      ]);
      default = "rofi";
    };

    bar = {
      type = nullOr (enum [
        "waybar"
        "ags"
        "quickshell"
      ]);
      default = "ags";
    };

    screenLocker = {
      type = nullOr (enum [
        "swaylock"
        "gtklock"
        "cosmic-greeter"
      ]);
      default = "gtklock";
      description = ''
        The lockscreen module to be loaded by home-manager.
      '';
    };

    noiseSuppressor = {
      type = nullOr (enum [
        "rnnoise"
        "noisetorch"
      ]);
      default = "rnnoise";
      description = ''
        The noise suppressor to be used for desktop systems with sound enabled.
      '';
    };
  };
}
