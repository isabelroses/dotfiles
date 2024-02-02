{
  inputs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkForce;
in {
  imports = [inputs.nixos-wsl.nixosModules.wsl];
  config = {
    wsl = {
      enable = true;
      defaultUser = config.modules.system.mainUser;
      startMenuLaunchers = true;
    };

    services.smartd.enable = mkForce false; # Unavailable - device lacks SMART capability.
    networking.tcpcrypt.enable = mkForce false;
  };
}
