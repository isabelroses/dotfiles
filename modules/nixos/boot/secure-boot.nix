{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  inherit (lib.modules) mkIf mkForce;
  inherit (lib.options) mkEnableOption;
  sys = config.garden.system.boot;
in
{
  # https://wiki.nixos.org/wiki/Secure_Boot
  # Secure Boot, my love keeping my valorant working on windows
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  options.garden.system.boot.secureBoot = mkEnableOption ''
    secure-boot and load necessary packages, say good bye to systemd-boot
  '';

  config = mkIf sys.secureBoot {
    garden.packages = { inherit (pkgs) sbctl; };

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
