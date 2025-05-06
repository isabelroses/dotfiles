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
  inherit (lib) genAttrs;
in
{
  home-manager = {
    verbose = true;
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "bak";

    users = genAttrs config.garden.system.users (name: {
      imports = [ ./${name} ];
    });

    extraSpecialArgs = {
      inherit
        self
        self'
        inputs
        inputs'
        ;
    };

    # we should define grauntied common modules here
    sharedModules = [ (self + /modules/home/default.nix) ];
  };
}
