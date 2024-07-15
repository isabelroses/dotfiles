{ lib, ... }:
let
  inherit (lib.options) mkOption;
  inherit (lib.types) enum nullOr;
in
{
  options.garden.programs.defaults = {
    terminal = mkOption {
      type = enum [
        "alacritty"
        "kitty"
        "wezterm"
        "foot"
      ];
      default = "wezterm";
    };

    fileManager = mkOption {
      type = enum [
        "thunar"
        "dolphin"
        "nemo"
      ];
      default = "thunar";
    };

    browser = mkOption {
      type = enum [
        "firefox"
        "chromium"
      ];
      default = "chromium";
    };

    editor = mkOption {
      type = enum [
        "nvim"
        "codium"
      ];
      default = "nvim";
    };

    launcher = mkOption {
      type = nullOr (enum [
        "rofi"
        "wofi"
      ]);
      default = "rofi";
    };

    bar = mkOption {
      type = nullOr (enum [
        "waybar"
        "ags"
      ]);
      default = "ags";
    };

    screenLocker = mkOption {
      type = nullOr (enum [
        "swaylock"
        "gtklock"
      ]);
      default = "gtklock";
      description = ''
        The lockscreen module to be loaded by home-manager.
      '';
    };

    noiseSuppressor = mkOption {
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
