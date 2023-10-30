{lib, ...}: let
  inherit (lib) mkDefault;
in {
  config.modules.programs = {
    gaming.enable = false;

    browsers = {
      chromium.enable = mkDefault false;
      firefox.enable = mkDefault false;
    };

    editors = {
      neovim.enable = mkDefault true;
      vscode.enable = mkDefault false;
      micro = mkDefault false;
    };

    fileManagers = {
      dolphin.enable = mkDefault false;
      nemo.enable = mkDefault false;
      thunar.enable = mkDefault false;
    };

    launchers = {
      rofi.enable = mkDefault false;
      wofi.enable = mkDefault false;
    };

    terminals = {
      alacritty.enable = mkDefault false;
      kitty.enable = mkDefault false;
    };

    zathura.enable = mkDefault false;
  };
}
