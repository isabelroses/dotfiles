{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.garden.programs.cosmic;
in
{
  options.garden.programs.cosmic = {
    enable = mkEnableOption "enable cosmic desktop environment";
  };

  config = mkIf cfg.enable {
    services.desktopManager.cosmic.enable = true;

    environment.cosmic.excludePackages = [
      pkgs.cosmic-edit
      pkgs.cosmic-term
      pkgs.cosmic-store
    ];

    garden.environment.loginManager = "cosmic-greeter";
  };
}
