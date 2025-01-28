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
  inherit (lib.modules) mkDefault;
  inherit (lib.attrsets) genAttrs;
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
        ;
    };

    users = genAttrs config.garden.system.users (name: ./${name});

    # we should define grauntied common modules here
    sharedModules = [
      inputs.beapkgs.homeManagerModules.default

      (self + /modules/home/default.nix)

      {
        home.stateVersion =
          if pkgs.stdenv.hostPlatform.isDarwin then "23.11" else config.system.stateVersion;

        # reload system units when changing configs
        systemd.user.startServices = mkDefault "sd-switch"; # or "legacy" if "sd-switch" breaks again

        # let HM manage itself when in standalone mode
        programs.home-manager.enable = true;
      }
    ];
  };
}
