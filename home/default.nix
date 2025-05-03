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
  inherit (lib.modules) mkIf;
  inherit (lib.attrsets) genAttrs;
  inherit (lib.options) mkEnableOption;
in
{
  options.garden.system.useHomeManager = mkEnableOption "Whether to use home-manager or not" // {
    default = true;
  };

  config = mkIf config.garden.system.useHomeManager {
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
  };
}
