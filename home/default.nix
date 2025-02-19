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
  inherit (lib.modules) mkIf mkDefault;
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

      users = genAttrs config.garden.system.users (name: ./${name});

      extraSpecialArgs = {
        inherit
          self
          self'
          inputs
          inputs'
          ;
      };

      # we should define grauntied common modules here
      sharedModules = [
        inputs.beapkgs.homeManagerModules.default

        (self + /modules/home/default.nix)

        {
          home.stateVersion = config.garden.system.stateVersion;

          # reload system units when changing configs
          systemd.user.startServices = mkDefault "sd-switch"; # or "legacy" if "sd-switch" breaks again

          # let HM manage itself when in standalone mode
          programs.home-manager.enable = true;
        }
      ];
    };
  };
}
