{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  inherit (lib.modules) mkIf mkForce;
  sys = config.garden.system.boot;
in
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  # Secure Boot, my love keeping my valorant working on windows
  config = mkIf sys.secureBoot {
    environment.systemPackages = [ pkgs.sbctl ];

    # Lanzaboote replaces the systemd-boot module.
    boot.loader.systemd-boot.enable = mkForce false;

    boot = {
      bootspec.enable = true;
      lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };
    };
  };
}
