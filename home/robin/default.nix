{ inputs, osConfig, ... }:
{
  imports = [
    inputs.beapkgs.homeManagerModules.default

    ./system # important system environment config
    ./packages # programs & their configurations, e.g. GUI apps
    ./services # system services, organized by display protocol
    ./themes # Application themeing
  ];

  config.home = {
    username = "robin";
    homeDirectory = osConfig.users.users.robin.home;
  };
}
