{
  lib,
  pkgs,
  self,
  self',
  config,
  inputs,
  inputs',
  ...
}:
let
  inherit (lib.modules) mkForce;
  inherit (lib.attrsets) genAttrs;
  inherit (config.garden.programs) defaults;
in
{
  home-manager = {
    verbose = true;
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "bak";

    extraSpecialArgs = {
      inherit
        inputs
        self
        inputs'
        self'
        defaults
        ;
    };

    users = genAttrs config.garden.system.users (name: ./${name});

    # we should define grauntied common modules here
    sharedModules = [
      {
        nix.package = mkForce config.nix.package;
        home.stateVersion = if pkgs.stdenv.isDarwin then "23.11" else config.system.stateVersion;
      }
    ];
  };
}
