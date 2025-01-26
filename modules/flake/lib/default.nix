# following https://github.com/NixOS/nixpkgs/blob/77ee426a4da240c1df7e11f48ac6243e0890f03e/lib/default.nix
# as a rough template we can create our own extensible lib and expose it to the flake
# we can then use that elsewhere like our hosts
{ inputs, ... }:
let
  lib0 = inputs.nixpkgs.lib;

  gardenLib = lib0.makeExtensible (
    self:
    let
      lib = self;
    in
    {
      template = import ./template; # templates, selections of code that are repeated
      hardware = import ./hardware.nix;
      helpers = import ./helpers.nix { inherit lib; };
      programs = import ./programs.nix { inherit lib; };
      secrets = import ./secrets.nix { inherit inputs; };
      services = import ./services.nix { inherit lib; };
      validators = import ./validators.nix { inherit lib; };

      # we have to rexport the functions we want to use, but don't want to refer to the whole lib
      # "path". e.g. lib.hardware.isx86Linux can be shortened to lib.isx86Linux
      # NOTE: never rexport templates
      inherit (self.builders) mkSystems;
      inherit (self.hardware) isx86Linux primaryMonitor ldTernary;
      inherit (self.helpers)
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
      inherit (self.programs) mkProgram;
      inherit (self.secrets) mkSecret mkSecretWithPath;
      inherit (self.services) mkGraphicalService mkHyprlandService mkServiceOption;
      inherit (self.validators)
        ifTheyExist
        isAcceptedDevice
        isWayland
        ifOneEnabled
        isModernShell
        anyHome
        ;
    }
  );

  # we need to extend gardenLib with the nixpkgs lib to get the full set of functions
  # if we do it the otherway around we will get errors saying mkMerge and so on don't exist
  finalLib = gardenLib.extend (_: _: lib0);
in
{
  flake.lib = finalLib;
  perSystem._module.args.lib = finalLib;
}
