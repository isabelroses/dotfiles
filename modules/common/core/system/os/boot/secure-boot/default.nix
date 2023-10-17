{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  sys = config.modules.system.boot;
in {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  config = mkIf sys.secureBoot {
    environment.systemPackages = [
      # Secure Boot, my love keeping my valorant working on windows
      pkgs.sbctl
    ];

    # Lanzaboote replaces the systemd-boot module.
    boot.loader.systemd-boot.enable = lib.mkForce false;

    boot = {
      bootspec.enable = true;
      lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };
    };
  };
}
