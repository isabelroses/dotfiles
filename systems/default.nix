{ self, inputs, ... }:
let
  inherit (self) lib;

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
  imports = [ inputs.easy-hosts.flakeModule ];

  config.easyHosts = {
    shared.specialArgs = { inherit lib; };

    perClass = class: {
      modules = [
        # import the class module, this contains the common configurations between all systems of the same class
        "${self}/modules/${class}/default.nix"

        (lib.lists.optionals (class != "iso") [
          # import the home module, which is users for configuring users via home-manager
          "${self}/home/default.nix"

          # import the base module, this contains the common configurations between all systems
          "${self}/modules/base/default.nix"
        ])
      ];
    };

    # This is the list of system configuration
    #
    # the defaults consists of the following:
    #  arch = "x86_64";
    #  class = "nixos";
    #  deployable = false;
    #  modules = [ ];
    #  specialArgs = { };
    hosts = {
      # isabel's hosts
      hydra.modules = [
        laptop
        graphical
      ];

      tatsumaki = {
        arch = "aarch64";
        class = "darwin";
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
        class = "iso";
        modules = [ headless ];
      };

      # robin's hosts
      cottage.modules = [
        laptop
        graphical
      ];

      wisp.modules = [
        wsl
      ];
    };
  };
}
