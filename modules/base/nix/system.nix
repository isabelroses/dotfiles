{
  lib,
  self,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkDefault;
  inherit (lib.hardware) ldTernary;
  inherit (lib.attrsets) optionalAttrs;
in
{
  system =
    {
      # this is the NixOS version that the configuration was generated with
      # this should be change to the version of the NixOS release that the configuration was generated with
      stateVersion = mkDefault (ldTernary pkgs "23.05" 4);

      # we can get the git rev that we are working on and set that to the configurationRevision
      # this *might* be useful for debugging
      configurationRevision = self.shortRev or self.dirtyShortRev or "dirty";
    }
    # if the system is darwin we need to set some extra options
    # this includes the darwinVersionSuffix and darwinRevision
    // optionalAttrs pkgs.stdenv.isDarwin {
      # i don't quite know why this is set but upstream does it so i will too
      checks.verifyNixPath = false;

      # very similar to the above configurationRevision settings
      darwinVersionSuffix = ".${self.shortRev or self.dirtyShortRev or "dirty"}";
      darwinRevision = self.rev or self.dirtyRev or "dirty";
    };
}
