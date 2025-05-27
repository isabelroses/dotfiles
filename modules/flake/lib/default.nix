# following https://github.com/NixOS/nixpkgs/blob/77ee426a4da240c1df7e11f48ac6243e0890f03e/lib/default.nix
# as a rough template we can create our own extensible lib and expose it to the flake
# we can then use that elsewhere like our hosts
{ lib, inputs, ... }:
let
  gardenLib = lib.fixedPoints.makeExtensible (final: {
    template = import ./template; # templates, selections of code that are repeated
    hardware = import ./hardware.nix;
    helpers = import ./helpers.nix { inherit lib; };
    programs = import ./programs.nix { inherit lib; };
    secrets = import ./secrets.nix { inherit inputs; };
    services = import ./services.nix { inherit lib; };
    validators = import ./validators.nix { inherit lib; };

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
    inherit (final.programs) mkProgram;
    inherit (final.secrets) mkUserSecret mkSystemSecret;
    inherit (final.services) mkGraphicalService mkHyprlandService mkServiceOption;
    inherit (final.validators)
      ifTheyExist
      ifOneEnabled
      anyHome
      ;
  });

  # I want to absorb the evergarden lib into the garden lib. We don't do this
  # with nixpkgs lib to keep it pure as it is used else where and leads to many
  # breakages
  ext = lib.fixedPoints.composeManyExtensions [
    (_: _: inputs.evergarden.lib)
  ];

  # we need to extend gardenLib with the nixpkgs lib to get the full set of functions
  # if we do it the otherway around we will get errors saying mkMerge and so on don't exist
  finalLib = gardenLib.extend ext;
in
{
  # expose our custom lib to the flake
  flake.lib = finalLib;
}
