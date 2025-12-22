{ self, pkgs, ... }:
let
  inherit (self.lib) isx86Linux;
in
{
  hardware.graphics = {
    enable = true;
    enable32Bit = isx86Linux pkgs;
  };
}
