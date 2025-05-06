{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) isx86Linux;
in
{
  config = mkIf config.garden.profiles.graphical.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = isx86Linux pkgs;
    };
  };
}
