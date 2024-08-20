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
    home.packages = optional pkgs.stdenv.isLinux inputs'.ghostty.packages.ghostty;

    xdg.configFile."ghostty/config".text = ''
      title = Ghostty

      shell-integration = none

      background-opacity = 0.95

      font-family = ${osConfig.garden.style.font.name}
      font-size = 13

      command = /etc/profiles/per-user/isabel/bin/fish --login

      theme = catppuccin-mocha
    '';
  };
}
