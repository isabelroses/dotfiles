# following https://github.com/NixOS/nixpkgs/blob/77ee426a4da240c1df7e11f48ac6243e0890f03e/lib/default.nix
# as a rough template we can create our own extensible lib and expose it to the flake
# we can then use that elsewhere like our hosts
{ inputs, withSystem, ... }:
let
  lib0 = inputs.nixpkgs.lib;

  gardenLib = lib0.makeExtensible (
    self:
    let
      lib = self;
    in
    {
      template = import ./template; # templates, selections of code that are repeated
      builders = import ./builders.nix { inherit lib inputs withSystem; };
      hardware = import ./hardware.nix;
      helpers = import ./helpers.nix { inherit lib; };
      secerets = import ./secrets.nix { inherit inputs; };
      services = import ./services.nix { inherit lib; };
      validators = import ./validators.nix { inherit lib; };

      inherit (self.builders) mkSystems mkNixosIsos;
      inherit (self.hardware) isx86Linux primaryMonitor ldTernary;
      inherit (self.helpers)
        filterNixFiles
        importNixFiles
        importNixFilesAndDirs
        boolToNum
        containsStrings
        indexOf
        intListToStringList
        ;
      inherit (self.secerets) mkSecret mkSecretWithPath;
      inherit (self.services) mkGraphicalService mkHyprlandService mkServiceOption;
      inherit (self.validators)
        ifTheyExist
        ifGroupsExist
        isAcceptedDevice
        isWayland
        ifOneEnabled
        isModernShell
        ;
    }
  );

  finalLib = gardenLib.extend (_: _: lib0);
in
{
  flake.lib = finalLib;
  perSystem = _: { _module.args.lib = finalLib; };
}
