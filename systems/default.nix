let
  # profiles module, these are sensible defaults for given hardware sets
  # or meta profiles that are used to configure the system based on the requirements of the given machine
  profilesPath = ../modules/profiles; # the base directory for the types module

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
in
{
  # this is how we get the custom module `config.hosts`
  imports = [ ./flake-module.nix ];

  # This is the list of system configuration
  #
  # the defaults consists of the following:
  #  arch = "x86_64";
  #  target = "nixos";
  #  deployable = false;
  #  modules = [ ];
  #  specialArgs = { };
  config.hosts = {
    # isabel's hosts
    hydra.modules = [
      laptop
      graphical
    ];

    tatsumaki = {
      arch = "aarch64";
      target = "darwin";
    };

    amaterasu.modules = [
      desktop
      graphical
    ];

    valkyrie.modules = [
      wsl
    ];

    minerva = {
      deployable = true;
      modules = [ server ];
    };

    lilith = {
      target = "iso";
      modules = [ headless ];
    };

    # comfy's hosts
    cottage.modules = [
      laptop
      graphical
    ];

    wisp.modules = [
      wsl
    ];
  };
}
