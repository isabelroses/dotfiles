{inputs, ...}: let
  inherit (inputs.nixpkgs) lib;
  inherit (lib) foldl recursiveUpdate;

  # wrap the import with a pre-inherited lib to avoid typing it over and over again
  # credits to @nrabulinski
  import' = path: let
    func = import path;
    args = lib.functionArgs func;
    requiredArgs = lib.filterAttrs (_: val: !val) args;
    defaultArgs = (lib.mapAttrs (_: _: null) requiredArgs) // {inherit lib;};
    functor = {__functor = _: attrs: func (defaultArgs // attrs);};
  in
    (func defaultArgs) // functor;

  builders = import' ./builders.nix {inherit inputs;};
  services = import' ./services.nix;
  validators = import' ./validators.nix;
  helpers = import' ./helpers.nix;
  hardware = import' ./hardware.nix;

  # abstractions over networking functions
  # dag library is a modified version of the one found in
  # rycee's NUR repository
  dag = import' ./networking/dag.nix;
  firewall = import' ./networking/firewall.nix {inherit dag;};
  namespacing = import' ./networking/namespacing.nix;

  # aliases for commonly used strings or functions
  aliases = import' ./aliases.nix;

  # recursively merges two attribute sets
  mergeRecursively = lhs: rhs: recursiveUpdate lhs rhs;
  importedLibs = [builders services validators helpers hardware aliases firewall namespacing dag];
in
  lib.extend (_: _: foldl mergeRecursively {} importedLibs)
