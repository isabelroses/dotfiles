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
      pkgs.freeze
    ];

    xdg.configFile."freeze/user.json".source = json.generate "user.json" {
      window = true;
      theme = "catppuccin-mocha";

      background = "#1e1e2e";

      shadow = false;
      padding = 0;
      margin = 0;

      line_height = 1.2;
      line_numbers = true;

      border = {
        radius = 8;
        width = 1;
        color = "#313244";
      };

      font = {
        family = "CommitMono";
        size = 13;
        ligatures = true;
      };
    };
  };
}
