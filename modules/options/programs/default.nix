{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
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
        vscode.enable = mkEnableOption "VScode editor" // {default = config.modules.programs.gui.enable;};
        micro.enable = mkEnableOption "Micro editor";
      };
    };

    cli = {
      enable = mkEnableOption "Enable CLI programs" // {default = true;};
      modernShell.enable = mkEnableOption "Enable programs for a more modern shell";
    };

    tui.enable = mkEnableOption "Enable TUI programs" // {default = true;};

    gui = {
      enable = mkEnableOption "Enable GUI programs";

      zathura.enable = mkEnableOption "Enable zathura PDF reader";

      launchers = {
        rofi.enable = mkEnableOption "Enable rofi launcher";
        wofi.enable = mkEnableOption "Enable wofi launcher";
      };

      bars = {
        ags.enable = mkEnableOption "Enable ags bar/launcher" // {default = config.modules.programs.gui.enable;};
        eww.enable = mkEnableOption "Enable eww bar/launcher";
        waybar.enable = mkEnableOption "Enable waybar";
      };

      browsers = {
        chromium = {
          enable = mkEnableOption "Chromium browser" // {default = config.modules.programs.gui.enable;};
          # TODO: make this do smt
          ungoogled = mkEnableOption "Enable ungoogled-chromium Tweaks";
        };

        firefox = {
          enable = mkEnableOption "Firefox browser";
          schizofox = mkEnableOption "Enable Schizofox Firefox Tweaks" // {default = true;};
        };
      };

      terminals = {
        alacritty.enable = mkEnableOption "Alacritty terminal emulator" // {default = config.modules.programs.gui.enable;};
        kitty.enable = mkEnableOption "Kitty terminal emulator";
        # TODO: wezterm.enable = mkEnableOption "WezTerm terminal emulator";
      };

      fileManagers = {
        thunar.enable = mkEnableOption "Enable thunar file manager" // {default = config.modules.programs.gui.enable;};
        dolphin.enable = mkEnableOption "Enable dolphin file manager";
        nemo.enable = mkEnableOption "Enable nemo file manager";
      };
    };
  };
}
