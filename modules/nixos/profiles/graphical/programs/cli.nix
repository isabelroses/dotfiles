{
  lib,
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
    programs = {
      # help manage android devices via command line
      adb.enable = true;

      # show network usage
      bandwhich.enable = true;
    };
  };
}
