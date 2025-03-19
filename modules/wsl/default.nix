{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  inherit (lib.modules) mkForce;
in
{
  imports = [
    ../nixos

    inputs.nixos-wsl.nixosModules.wsl
  ];

  config = {
    wsl = {
      enable = true;
      defaultUser = config.garden.system.mainUser;
      startMenuLaunchers = true;

      interop = {
        includePath = false;
        register = true;
      };
    };

    # disable features that don't work or don't make sense in WSL
    services = {
      smartd.enable = mkForce false;
      xserver.enable = mkForce false;
    };

    networking.tcpcrypt.enable = mkForce false;

    # resolv.conf is managed by wsl
    services.resolved.enable = mkForce false;
    security.apparmor.enable = mkForce false;

    # allow me to open files and links in Windows from WSL
    environment = {
      variables.BROWSER = mkForce "wsl-open";
      systemPackages = [ pkgs.wsl-open ];
    };
  };
}
