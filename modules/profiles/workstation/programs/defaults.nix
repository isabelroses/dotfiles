{lib, ...}: let
  inherit (lib) mkDefault;
in {
  config.modules.programs = {
    browsers = {
      chromium = {
        enable = mkDefault true;
        ungoogled = mkDefault false;
      };

      firefox = {
        enable = mkDefault false;
        schizofox = mkDefault true;
      };
    };

    editors = {
      neovim.enable = mkDefault true;
      vscode.enable = mkDefault true;
      micro.enable = mkDefault false;
    };

    fileManagers = {
      dolphin.enable = mkDefault false;
      nemo.enable = mkDefault false;
      thunar.enable = mkDefault true;
    };

    launchers = {
      rofi.enable = mkDefault false;
      wofi.enable = mkDefault false;
    };

    bars = {
      ags.enable = true;
      eww.enable = false;
      waybar.enable = false;
    };

    terminals = {
      alacritty.enable = mkDefault false;
      kitty.enable = mkDefault true;
    };

    zathura.enable = mkDefault true;
  };
}
