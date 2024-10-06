{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optional;

  cfg = osConfig.garden.programs.ghostty;
in
{
  config = mkIf cfg.enable {
    home.packages = optional pkgs.stdenv.hostPlatform.isLinux cfg.package;

    xdg.configFile."ghostty/config".text = ''
      shell-integration = none

      command = /etc/profiles/per-user/isabel/bin/fish --login

      theme = catppuccin-mocha
      background-opacity = 0.95
      cursor-style = bar
      window-padding-x = 4,4
      window-decoration = ${toString pkgs.stdenv.hostPlatform.isDarwin}
      gtk-titlebar = false

      window-save-state = always

      font-family = ${osConfig.garden.style.font.name}
      font-size = 13
    '';
  };
}
