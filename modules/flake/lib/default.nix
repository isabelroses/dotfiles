# following https://github.com/NixOS/nixpkgs/blob/77ee426a4da240c1df7e11f48ac6243e0890f03e/lib/default.nix
# as a rough template we can create our own extensible lib and expose it to the flake
# we can then use that elsewhere like our hosts
{ lib, inputs, ... }:
let
  gardenLib = lib.fixedPoints.makeExtensible (final: {
    # keep-sorted start block=yes
    hardware = import ./hardware.nix;
    helpers = import ./helpers.nix { inherit lib; };
    secrets = import ./secrets.nix { inherit inputs; };
    services = import ./services.nix { inherit lib; };
    template = import ./template; # templates, selections of code that are repeated
    validators = import ./validators.nix { inherit lib; };
    # keep-sorted end

    # we have to rexport the functions we want to use, but don't want to refer to the whole lib
    # "path". e.g. gardenLib.hardware.isx86Linux can be shortened to gardenLib.isx86Linux
    # NOTE: never rexport templates
    inherit (final.hardware) isx86Linux primaryMonitor ldTernary;
    inherit (final.helpers)
      mkPubs
      giturl
      filterNixFiles
      importNixFiles
      importNixFilesAndDirs
      boolToNum
      containsStrings
      indexOf
      intListToStringList
      ;
    inherit (final.secrets) mkSystemSecret;
    inherit (final.services) mkGraphicalService mkServiceOption;
    inherit (final.validators)
      ifTheyExist
      ifOneEnabled
      anyHome
      ;
  });
in
{
  # expose our custom lib to the flake
  flake.lib = gardenLib;
}
