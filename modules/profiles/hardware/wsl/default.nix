{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  inherit (lib) mkForce;
in
{
  imports = [ inputs.nixos-wsl.nixosModules.wsl ];

  config = {
    wsl = {
      enable = true;
      defaultUser = config.garden.system.mainUser;
      startMenuLaunchers = true;
    };

    # disable features that don't work or don't make sense in WSL
    services = {
      smartd.enable = mkForce false;
      xserver.enable = mkForce false;
    };

    networking.tcpcrypt.enable = mkForce false;

    # allow me to open files and links in Windows from WSL
    environment = {
      variables.BROWSER = mkForce "wsl-open";
      systemPackages = with pkgs; [ wsl-open ];
    };
  };
}
