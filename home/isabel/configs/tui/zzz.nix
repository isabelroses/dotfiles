{
  lib,
  inputs',
  osConfig,
  ...
}: let
  inherit (lib) mkIf;
  cfg = osConfig.modules.programs.cli;
in {
  config = mkIf (cfg.enable && cfg.modernShell.enable) {
    home.packages = [
      inputs'.zzz.packages.default
    ];

    xdg.configFile."zzz/config.yaml".text = ''
      default_language: go
    '';
  };
}
