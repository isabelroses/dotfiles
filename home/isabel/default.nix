{
  lib,
  inputs,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkDefault;
in
{
  imports = [
    inputs.beapkgs.homeManagerModules.default

    ./configs # per application configuration
    ./system # important system environment config
    ./packages # programs that are used, e.g. GUI apps
    ./services # system services, organized by display protocol
    ./themes # Application themeing
  ];

  config = {
    # reload system units when changing configs
    systemd.user.startServices = mkDefault "sd-switch"; # or "legacy" if "sd-switch" breaks again

    home = {
      username = "isabel";
      homeDirectory = osConfig.users.users.isabel.home;
    };

    # let HM manage itself when in standalone mode
    programs.home-manager.enable = true;
  };
}
