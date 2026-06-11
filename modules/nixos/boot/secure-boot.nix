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

  options.garden.system.boot.secureBoot = mkEnableOption "secure-boot and load necessary packages";

  config = mkIf sys.secureBoot {
    garden.packages = { inherit (pkgs) sbctl; };

    boot = {
      # Lanzaboote replaces the systemd-boot module.
      loader.systemd-boot.enable = mkForce false;

      lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
    };
  };
}
