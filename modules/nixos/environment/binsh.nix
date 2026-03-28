# This *should* not break anything, but it theory it might...
# on the other hand it should also make our scripts run somewhat faster, so i'll take it
# <https://discourse.nixos.org/t/making-nixpkgs-less-dependent-on-bash/76443?u=isabelroses>
{ lib, pkgs, ... }:
{
  environment.binsh = lib.getExe pkgs.dash;
}
