{
  lib,
  self,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault ldTernary;
in
{
  system = {
    # this is the NixOS version that the configuration was generated with
    # this should be change to the version of the NixOS release that the configuration was generated with
    stateVersion = mkDefault (ldTernary pkgs "23.05" 4);

    # we can get the git rev that we are working on and set that to the configurationRevision
    # this *might* be useful for debugging
    configurationRevision = self.shortRev or self.dirtyShortRev;
  };
}
