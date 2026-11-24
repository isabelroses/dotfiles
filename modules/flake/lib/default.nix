# following https://github.com/NixOS/nixpkgs/blob/77ee426a4da240c1df7e11f48ac6243e0890f03e/lib/default.nix
# as a rough template we can create our own extensible lib and expose it to the flake
# we can then use that elsewhere like our hosts
{
  lib,
  inputs,
  pkgsFor,
}:

lib.fixedPoints.makeExtensible (final: {
  # keep-sorted start block=yes
  helpers = import ./helpers.nix { inherit lib; };
  mkHost = import ./mkhost.nix { inherit inputs lib pkgsFor; };
  modules = import ./modules.nix { inherit lib inputs; };
  palette = import ./palette.nix;
  validators = import ./validators.nix { inherit lib; };
  # keep-sorted end

  # we have to rexport the functions we want to use, but don't want to refer to the whole lib
  # "path". e.g. gardenLib.helpers.giturl can be shortened to gardenLib.giturl
  # NOTE: never rexport templates
  inherit (final.helpers) mkPubs giturl;
  inherit (final.modules) mkService mkSecret journalJail;
  inherit (final.validators) anyHome;
})
