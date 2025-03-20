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
  config = mkIf (hasProfile config [ "headless" ]) {
    # print the URL instead on servers
    environment.variables.BROWSER = "echo";
  };
}
