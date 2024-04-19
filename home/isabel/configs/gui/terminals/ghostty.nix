{
  lib,
  pkgs,
  inputs',
  osConfig,
  ...
}: let
  inherit (lib) mkIf;
in {
  config = mkIf osConfig.modules.programs.gui.terminals.ghostty.enable {
    home.packages = mkIf pkgs.stdenv.isLinux [
      inputs'.ghostty.packages.default
    ];

    xdg.configFile."ghostty/config".text = ''
      title = Ghostty

      background-opacity = 0.8

      font-family = Commit Mono
      font-size = 13

      command = /etc/profiles/per-user/isabel/bin/fish --login

      background           = #1E1E2E
      foreground           = #CDD6F4
      cursor-color         = #F5E0DC
      selection-background = #F5E0DC
      selection-foreground = #1E1E2E

      # black
      palette = 0=#45475A
      palette = 8=#585B70
      # red
      palette = 1=#F38BA8
      palette = 9=#F38BA8
      # green
      palette = 2=#A6E3A1
      palette = 10=#A6E3A1
      # yellow
      palette = 3=#F9E2AF
      palette = 11=#F9E2AF
      # blue
      palette = 4=#89B4FA
      palette = 12=#89B4FA
      # magenta
      palette = 5=#F5C2E7
      palette = 13=#F5C2E7
      # cyan
      palette = 6=#94E2D5
      palette = 14=#94E2D5
      # white
      palette = 7=#BAC2DE
      palette = 15=#A6ADC8
    '';
  };
}
