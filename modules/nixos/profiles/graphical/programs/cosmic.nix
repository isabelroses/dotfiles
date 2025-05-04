{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib.modules) mkIf;
in
{
  imports = [ inputs.cosmic.nixosModules.default ];

  config = mkIf false {
    services.desktopManager.cosmic.enable = true;

    environment.cosmic.excludePackages = [
      pkgs.cosmic-edit
      pkgs.cosmic-term
      pkgs.cosmic-store
    ];

    garden.environment.loginManager = "cosmic-greeter";
  };
}
