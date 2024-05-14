{ pkgs, lib, ... }:
{
  environment = {
    # packages that should be on all deviecs
    systemPackages = with pkgs; [
      git
      curl
      wget
      pciutils
      lshw
    ];

    # disable all packages installed by default, i prefer my own packages
    defaultPackages = lib.mkForce [ ];
  };
}
