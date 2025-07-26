{ lib, config, ... }:
let
  inherit (lib) filterAttrs attrNames;
in
{
  system.nixos.tags = attrNames (filterAttrs (_: v: v.enable) config.garden.profiles);
}
