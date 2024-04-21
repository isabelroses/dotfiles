{
  lib,
  self',
  osConfig,
  ...
}: let
  inherit (lib) mkIf;
  cfg = osConfig.modules.programs.cli;
in {
  config = mkIf (cfg.enable && cfg.modernShell.enable) {
    home.packages = [
      self'.packages.nap
    ];

    xdg.configFile."nap/config.yaml".text = ''
      default_language: go
      theme: "catppuccin-mocha"

      background: "#1e1e2e"
      foreground: "#cdd6f4"
      primary_color: "#74c7ec"
      primary_color_subdued: "#74c7ec"
      green: "#a6e3a1"
      bright_green: "#f9e2af"
      bright_red: "#eba0ac"
      red: "#f38ba8"
      black: "#cdd6f4"
      gray: "#313244"
      white: "#11111b"
    '';
  };
}
