{
  lib,
  pkgs,
  inputs',
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optional;
in
{
  config = mkIf osConfig.garden.programs.gui.terminals.ghostty.enable {
    home.packages = optional pkgs.stdenv.hostPlatform.isLinux inputs'.ghostty.packages.ghostty;

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
