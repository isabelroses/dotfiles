{lib, ...}: let
  inherit (lib) mkDefault;
in {
  imports = [./gaming.nix];

  config.modules.programs = {
    browsers = {
      chromium = {
        enable = mkDefault false;
        ungoogled = mkDefault true;
      };

      firefox = {
        enable = mkDefault true;
        schizofox = mkDefault true;
      };
    };

    editors = {
      neovim.enable = mkDefault true;
      vscode.enable = mkDefault true;
      micro = mkDefault false;
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

    terminals = {
      alacritty.enable = mkDefault false;
      kitty.enable = mkDefault true;
    };

    zathura.enable = mkDefault true;
  };
}
