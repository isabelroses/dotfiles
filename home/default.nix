{
  lib,
  self,
  root,
  config,
  inputs,
  ...
}:
let
  inherit (lib.attrsets) genAttrs;
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
        inputs
        root
        ;
    };

    # we should define grauntied common modules here
    sharedModules = [ (root + /modules/home/default.nix) ];
  };
}
