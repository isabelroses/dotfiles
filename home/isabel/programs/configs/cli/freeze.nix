{
  lib,
  pkgs,
  osConfig,
  ...
}: let
  json = pkgs.formats.json {};

  inherit (lib) mkIf isModernShell;
in {
  config = mkIf (isModernShell osConfig) {
    home.packages = mkIf pkgs.stdenv.isLinux [
      pkgs.charm-freeze
    ];

    xdg.configFile."freeze/user.json".source = json.generate "user.json" {
      theme = "catppuccin-mocha";
      background = "#1e1e2e";

      window = true;
      shadow = false;
      padding = [20 40 20 20];
      margin = 0;

      line_height = 1.2;
      line_numbers = true;

      # border = {
      #   radius = 8;
      #   width = 1;
      #   color = "#313244";
      # };

      font = {
        family = "CommitMono";
        size = 14;
      };
    };
  };
}
