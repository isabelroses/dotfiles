{
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (self.lib) isx86Linux;
in
{
  hardware.graphics = {
    enable = true;

    # 32-bit GL is only ever used by 32-bit userspace (steam, wine), so a
    # headless system has no use for it no matter which gpu it has
    enable32Bit = config.garden.profiles.graphical.enable && isx86Linux pkgs;
  };
}
