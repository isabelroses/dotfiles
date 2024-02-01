{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.modules.programs;
in {
  imports = [
    ./defaults.nix
    ./gaming.nix
  ];

  options.modules.programs = {
    # For programs that are not exactly limited to cli, tui or gui
    agnostic = {
      git.signingKey = mkOption {
        type = types.str;
        default = "";
        description = "The default gpg key used for signing commits";
      };

      editors = {
        neovim.enable = mkEnableOption "Neovim editor" // {default = true;};
        vscode.enable = mkEnableOption "VScode editor" // {default = cfg.gui.enable;};
        micro.enable = mkEnableOption "Micro editor";
      };

      wine.enable = mkEnableOption "Enable wine";
    };

    cli = {
      enable = mkEnableOption "Enable CLI programs" // {default = true;};
      modernShell.enable = mkEnableOption "Enable programs for a more modern shell";
    };

    tui.enable = mkEnableOption "Enable TUI programs" // {default = true;};

    gui = {
      enable = mkEnableOption "Enable GUI programs";

      zathura.enable = mkEnableOption "Enable zathura PDF reader";

      kdeconnect = {
        enable = mkEnableOption "Enable kdeconnect";
        indicator.enable = mkEnableOption "Enable kdeconnect indicator";
      };

      launchers = {
        rofi.enable = mkEnableOption "Enable rofi launcher";
        wofi.enable = mkEnableOption "Enable wofi launcher";
      };

      bars = {
        ags.enable = mkEnableOption "Enable ags bar/launcher" // {default = cfg.gui.enable;};
        eww.enable = mkEnableOption "Enable eww bar/launcher";
        waybar.enable = mkEnableOption "Enable waybar";
      };

      browsers = {
        chromium = {
          enable = mkEnableOption "Chromium browser" // {default = cfg.gui.enable;};
          ungoogled = mkEnableOption "Enable ungoogled-chromium Tweaks";
        };

        firefox = {
          enable = mkEnableOption "Firefox browser";
          schizofox = mkEnableOption "Enable Schizofox Firefox Tweaks" // {default = true;};
        };
      };

      terminals = {
        kitty.enable = mkEnableOption "Kitty terminal emulator" // {default = cfg.gui.enable;};
        alacritty.enable = mkEnableOption "Alacritty terminal emulator";
        wezterm.enable = mkEnableOption "WezTerm terminal emulator";
      };

      fileManagers = {
        thunar.enable = mkEnableOption "Enable thunar file manager" // {default = cfg.gui.enable;};
        dolphin.enable = mkEnableOption "Enable dolphin file manager";
        nemo.enable = mkEnableOption "Enable nemo file manager";
      };
    };
  };
}
