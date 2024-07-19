{ lib, config, ... }:
let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) str;

  cfg = config.garden.programs;
in
{
  imports = [ ./defaults.nix ];

  options.garden.programs = {
    # For programs that are not exactly limited to cli, tui or gui
    agnostic = {
      git.signingKey = mkOption {
        type = str;
        default = "";
        description = "The default gpg key used for signing commits";
      };

      editors = {
        neovim.enable = mkEnableOption "Neovim editor" // {
          default = true;
        };
        vscode.enable = mkEnableOption "VScode editor";
        zed.enable = mkEnableOption "Zed editor";
        micro.enable = mkEnableOption "Micro editor";
      };

      wine.enable = mkEnableOption "Enable wine";
      pentesting.enable = mkEnableOption "Enable packages designed for pentesting";
    };

    cli = {
      enable = mkEnableOption "Enable CLI programs" // {
        default = true;
      };
      modernShell.enable = mkEnableOption "Enable programs for a more modern shell";
    };

    tui.enable = mkEnableOption "Enable TUI programs" // {
      default = true;
    };

    gui = {
      enable = mkEnableOption "Enable GUI programs";

      zathura.enable = mkEnableOption "Enable zathura PDF reader";
      discord.enable = mkEnableOption "Enable the discord client";

      kdeconnect = {
        enable = mkEnableOption "Enable kdeconnect";
        indicator.enable = mkEnableOption "Enable kdeconnect indicator";
      };

      launchers = {
        rofi.enable = mkEnableOption "Enable rofi launcher";
        wofi.enable = mkEnableOption "Enable wofi launcher";
      };

      bars = {
        ags.enable = mkEnableOption "Enable ags bar/launcher" // {
          default = cfg.gui.enable;
        };
        waybar.enable = mkEnableOption "Enable waybar";
      };

      browsers = {
        chromium = {
          enable = mkEnableOption "Chromium browser" // {
            default = cfg.gui.enable;
          };
          ungoogled = mkEnableOption "Enable ungoogled-chromium Tweaks";
          thorium = mkEnableOption "Enable thorium Tweaks" // {
            default = true;
          };
        };

        firefox.enable = mkEnableOption "Firefox browser";
      };

      terminals = {
        wezterm.enable = mkEnableOption "WezTerm terminal emulator" // {
          default = cfg.gui.enable;
        };
        ghostty.enable = mkEnableOption "Ghostty terminal emulator";
        kitty.enable = mkEnableOption "Kitty terminal emulator";
        alacritty.enable = mkEnableOption "Alacritty terminal emulator";
      };

      fileManagers = {
        thunar.enable = mkEnableOption "Enable thunar file manager" // {
          default = cfg.gui.enable;
        };
        dolphin.enable = mkEnableOption "Enable dolphin file manager";
        nemo.enable = mkEnableOption "Enable nemo file manager";
      };
    };
  };
}
