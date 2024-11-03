{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  inherit (lib.modules) mkIf;

  env = config.garden.environment;
in
{
  imports = [ inputs.cosmic.nixosModules.default ];

  config = mkIf (env.desktop == "cosmic") {
    services.desktopManager.cosmic.enable = true;

    environment.cosmic.excludePackages = [
      pkgs.cosmic-edit
      pkgs.cosmic-term
      pkgs.cosmic-store
      pkgs.cosmic-idle
    ];

    garden = {
      environment.loginManager = "cosmic-greeter";

      programs.defaults = {
        fileManager = "cosmic-files";
        launcher = "cosmic-launcher";
      };
    };
  };
}
