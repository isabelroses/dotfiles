{ lib, pkgs, ... }:
let
  inherit (lib.options) mkOption;
  inherit (lib.types) enum nullOr;
  inherit (lib.hardware) ldTernary;
in
{
  options.garden.programs.defaults = {
    shell = mkOption {
      type = enum [
        "bash"
        "zsh"
        "fish"
        "nushell"
      ];
      default = ldTernary pkgs "bash" "zsh";
    };

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
        "cosmic-files"
        "thunar"
        "dolphin"
        "nemo"
      ];
      default = "cosmic-files";
    };

    browser = mkOption {
      type = enum [
        "firefox"
        "chromium"
        "thorium"
      ];
      default = "thorium";
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
        "cosmic-launcher"
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
        "cosmic-greeter"
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
