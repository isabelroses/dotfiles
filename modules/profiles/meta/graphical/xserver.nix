{ pkgs, ... }:
{
  services.xserver = {
    enable = false;

    excludePackages = [ pkgs.xterm ];
  };
}
