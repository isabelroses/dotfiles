{ inputs, osConfig, ... }:
{
  imports = [
    inputs.beapkgs.homeManagerModules.default

    ./configs # per application configuration
    ./system # important system environment config
    ./packages # programs that are used, e.g. GUI apps
    ./services # system services, organized by display protocol
    ./themes # Application themeing
  ];

  config.home = {
    username = "isabel";
    homeDirectory = osConfig.users.users.isabel.home;
  };
}
