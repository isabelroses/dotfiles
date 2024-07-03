{ lib, ... }:
let
  inherit (lib) mkOption types mdDoc;
in
{
  options.garden.programs.defaults = {
    terminal = mkOption {
      type = types.enum [
        "alacritty"
        "kitty"
        "wezterm"
        "foot"
      ];
      default = "wezterm";
    };

    fileManager = mkOption {
      type = types.enum [
        "thunar"
        "dolphin"
        "nemo"
      ];
      default = "thunar";
    };

    browser = mkOption {
      type = types.enum [
        "firefox"
        "chromium"
      ];
      default = "chromium";
    };

    editor = mkOption {
      type = types.enum [
        "nvim"
        "codium"
      ];
      default = "nvim";
    };

    launcher = mkOption {
      type =
        with types;
        nullOr (enum [
          "rofi"
          "wofi"
        ]);
      default = "rofi";
    };

    bar = mkOption {
      type =
        with types;
        nullOr (enum [
          "waybar"
          "ags"
        ]);
      default = "ags";
    };

    screenLocker = mkOption {
      type =
        with types;
        nullOr (enum [
          "swaylock"
          "gtklock"
        ]);
      default = "gtklock";
      description = mdDoc ''
        The lockscreen module to be loaded by home-manager.
      '';
    };

    noiseSuppressor = mkOption {
      type =
        with types;
        nullOr (enum [
          "rnnoise"
          "noisetorch"
        ]);
      default = "rnnoise";
      description = mdDoc ''
        The noise suppressor to be used for desktop systems with sound enabled.
      '';
    };
  };
}
