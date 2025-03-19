{
  lib,
  pkgs,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) hasProfile;
in
{
  config = mkIf (hasProfile config [ "graphical" ]) {
    services.xserver = {
      enable = false;

      excludePackages = [ pkgs.xterm ];
    };
  };
}
