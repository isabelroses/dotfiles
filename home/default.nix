{
  config,
  inputs,
  self,
  inputs',
  self',
  lib,
  ...
}: let
  inherit (config) modules;
  env = modules.usrEnv;
  defaults = config.modules.programs.default;
in {
  home-manager = lib.mkIf env.useHomeManager {
    verbose = true;
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "bak";
    extraSpecialArgs = {inherit inputs self inputs' self' defaults;};
    users = lib.genAttrs config.modules.system.users (name: ./${name});
  };
}
