{ lib, pkgs, ... }:
{
  # packages that should be on all deviecs
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    pciutils
    lshw
  ];
}
