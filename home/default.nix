{
  config,
  inputs,
  self,
  inputs',
  self',
  lib,
  ...
}: let
  inherit (config.modules.programs) defaults;
in {
  home-manager = {
    verbose = true;
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "bak";
    extraSpecialArgs = {inherit inputs self inputs' self' defaults;};
    users = lib.genAttrs config.modules.system.users (name: ./${name});
  };
}
