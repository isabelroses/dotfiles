let
  # modules
  modulePath = ../modules; # the base module path

  # base modules, is the base of this system configuration and are shared across all systems (so the basics)
  base = modulePath + /base;

  # profiles module, these are sensible defaults for given hardware sets
  # or meta profiles that are used to configure the system based on the requirements of the given machine
  profilesPath = modulePath + /profiles; # the base directory for the types module

  # hardware profiles
  laptop = profilesPath + /laptop; # for laptop type configurations
  desktop = profilesPath + /desktop; # for desktop type configurations
  # for server type configurations
  server = [
    headless
    (profilesPath + /server)
  ];
  # for wsl systems
  wsl = [
    headless
    (profilesPath + /wsl)
  ];

  # meta profiles
  graphical = profilesPath + /graphical; # for systems that have a graphical interface
  headless = profilesPath + /headless; # for headless systems

  # home-manager
  homes = ../home; # home-manager configurations

  # a list of shared modules, that means they need to be in almost all configs
  shared = [
    base
    homes
  ];
in
{
  # this is how we get the custom module `config.hosts`
  imports = [ ./flake-module.nix ];

  # This is the list of system configuration
  #
  # the defaults consists of the following:
  #  arch = "x86_64";
  #  target = "nixos";
  # deployable = false;
  #  modules = [ ];
  #  specialArgs = { };
  config.hosts = {
    hydra.modules = [
      laptop
      graphical
      shared
    ];

    tatsumaki = {
      arch = "aarch64";
      target = "darwin";
      modules = [ shared ];
    };

    amaterasu.modules = [
      desktop
      graphical
      shared
    ];

    valkyrie.modules = [
      wsl
      shared
    ];

    minerva = {
      deployable = true;
      modules = [
        server
        shared
      ];
    };

    lilith = {
      target = "iso";
      modules = [ headless ];
    };
  };
}
