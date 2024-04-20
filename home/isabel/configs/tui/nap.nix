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
      primary_color: "#f5c2e7"
      primary_color_subdued: "#f5e0dc"
      green: "#a6e3a1"
      bright_green: "#f9e2af"
      bright_red: "#eba0ac"
      red: "#f38ba8"
      black: "#11111b"
      gray: "#313244"
      white: "#bac2de"
    '';
  };
}
