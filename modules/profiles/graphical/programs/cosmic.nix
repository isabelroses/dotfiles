{
  lib,
  pkgs,
  self,
  config,
  inputs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) anyHome;

  cond = anyHome config (v: v == "cosmic") [
    "garden"
    "environment"
    "desktop"
  ];
in
{
  imports = [ inputs.cosmic.nixosModules.default ];

  config = mkIf cond {
    services.desktopManager.cosmic.enable = true;

    environment.cosmic.excludePackages = [
      pkgs.cosmic-edit
      pkgs.cosmic-term
      pkgs.cosmic-store
    ];

    garden.environment.loginManager = "cosmic-greeter";
  };
}
