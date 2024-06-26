{
  lib,
  self,
  self',
  config,
  inputs,
  inputs',
  ...
}:
let
  inherit (lib) mkForce;
  inherit (config.modules.programs) defaults;
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

    users = lib.genAttrs config.modules.system.users (name: ./${name});

    # we should define grauntied common modules here
    sharedModules = [ { nix.package = mkForce config.nix.package; } ];
  };
}
