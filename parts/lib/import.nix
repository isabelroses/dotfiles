{inputs}: let
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

  # templates, selections of code and etc that are repeated
  template = import' ./template;

  # recursively merges two attribute sets
  importedLibs = [builders services validators helpers hardware template];
in
  lib.extend (_: _: foldl recursiveUpdate {} importedLibs)
