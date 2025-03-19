{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.lists) mkIf;
  inherit (self.lib.validators) hasProfile;
in
{
  config = mkIf (hasProfile config [ "graphical" ]) {
    # print the URL instead on servers
    environment.variables.BROWSER = "echo";
  };
}
