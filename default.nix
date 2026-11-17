{
  system ? builtins.currentSystem,
}:
let
  # the repo as a plain path. never interpolate it into a string on its own,
  # that copies the whole checkout, .git included, into the store
  root = ./.;

  sources = import ./npins;

  # nixpkgs' lib does not depend on the system, so every instance shares it
  lib = import "${sources.nixpkgs}/lib";

  # our own lib: what we take from each source, how a host is evaluated, and
  # what the modules call
  gardenLib = import ./modules/output/lib { inherit lib root; };

  # This is the list of system configuration
  #
  # the defaults consists of the following:
  #  arch = "x86_64";
  #  class = "nixos";
  hosts = {
    # keep-sorted start block=yes newline_separated=yes
    amaterasu = { };

    freyja = { };

    isis = { };

    lilith = {
      class = "iso";
    };

    minerva = { };

    skadi = {
      arch = "aarch64";
    };

    tatsumaki = {
      arch = "aarch64";
      class = "darwin";
    };
    # keep-sorted end
  };

  # the tracked files of the repo and the commit they are at, the way a flake's
  # `self` was. only the revision and the few things that need a whole tree
  # force it, everything else reads `root`
  repo =
    let
      # ci checks out a shallow clone
      git = builtins.fetchGit {
        url = root;
        shallow = true;
      };
    in
    if !builtins.pathExists (root + /.git) then
      { outPath = root; }
    # fetchGit still names a commit for a dirty tree, all zeros. a flake does not
    else if git ? dirtyShortRev then
      removeAttrs git [
        "rev"
        "shortRev"
      ]
    else
      git;

  output =
    instance:
    let
      inherit (instance.inputs) pkgs;

      outputDir = root + /modules/output;
      importOutput = path: import (outputDir + path);

      # what modules, packages and checks call `self`: these outputs
      self = instance.output;
    in
    repo
    // {
      # a raw unfilted scope of packages
      packages = importOutput /packages {
        inherit pkgs root;
        inherit (instance) inputs;
        inherit self;
      };

      devShells.default = pkgs.callPackage (outputDir + /programs/shell.nix) {
        treefmt-wrapped = self.formatter;
      };

      lib = gardenLib;

      checks = importOutput /checks {
        inherit pkgs self;
      };

      formatter = pkgs.callPackage (outputDir + /programs/formatter.nix) { };

      hosts = lib.mapAttrs (gardenLib.mkHost instance.forSystem) hosts;
    };

  new =
    system:
    let
      instance = {
        inherit system forSystem;
        inputs = gardenLib.inputs sources system;
        output = output instance;
      };
    in
    instance;

  # one instance per system a host runs on, plus the one this file was asked
  # for, so two hosts on a system share a nixpkgs
  systems = [ system ] ++ map gardenLib.hostSystem (lib.attrValues hosts);
  instances = lib.genAttrs systems new;
  forSystem =
    system: instances.${system} or (throw "no host runs on ${system}, so there is no instance of it");

  instance = forSystem system;
in
instance.output // { inherit (instance) inputs; }
