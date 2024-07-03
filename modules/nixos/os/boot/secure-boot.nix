{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkForce;
  sys = config.modules.system.boot;
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
