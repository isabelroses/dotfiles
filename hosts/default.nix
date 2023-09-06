{
  self,
  lib,
  withSystem,
  ...
}: let
  inherit (self) inputs;
  inherit (lib) concatLists mkNixosSystem mkNixosIso;

  modulePath = ../modules;
  options = modulePath + /options; # the module that provides the options for my system configurations

  # common modules, to be shared across all systems
  commonModules = modulePath + /common; # the path where common modules reside
  core = commonModules + /core; # the self-proclaimed sane defaults for all my systems
  secrets = commonModules + /secrets;

  # system types, split up per system
  deviceType = commonModules + /types; # the path where device type modules reside
  server = deviceType + /server; # for devices that are of the server type - provides online services
  laptop = deviceType + /laptop; # for devices that are of the laptop type - provides power optimizations
  desktop = commonModules + /types/desktop; # for devices that are of the desktop type - any device that is stationary
  workstation = deviceType + /workstation; # for devices that are of workstation type - any device that is for daily use
  #hybrid = [server laptop];

  # extra modules, likely optional but possibly critical
  extraModules = modulePath + /extra; # the path where extra modules reside
  sharedModules = extraModules + /shared; # shared modules

  ## home-manager ##
  home = ../home; # home-manager configurations for hosts that need home-manager
  homes = [hm home]; # combine hm flake input and the home module to be imported together

  ## flake inputs ##
  hm = inputs.home-manager.nixosModules.home-manager; # home-manager nixos module
  cat = inputs.catppuccin.nixosModules.catppuccin;

  # a list of shared modules that ALL systems need
  shared = [
    core # the "sane" default shared across systems
    options
    sharedModules
    cat # for the quick themeing
    secrets
  ];

  # extraSpecialArgs that all hosts need
  sharedArgs = {inherit inputs self lib;};
in {
  hydra = mkNixosSystem {
    inherit withSystem;
    system = "x86_64-linux";
    modules =
      [
        ./hydra
        workstation
        laptop
      ]
      ++ concatLists [
        shared
        homes
        /*
        hybrid
        */
      ];
    specialArgs = sharedArgs;
  };

  # fuck nvidia - Linus "the linux" Torvalds
  amatarasu = mkNixosSystem {
    inherit withSystem;
    system = "x86_64-linux";
    modules =
      [
        ./amatarasu
        desktop
        workstation
      ]
      ++ concatLists [shared homes];
    specialArgs = sharedArgs;
  };

  bernie = mkNixosSystem {
    inherit withSystem;
    system = "x86_64-linux";
    modules =
      [
        ./bernie
        server
      ]
      ++ concatLists [shared homes];
    specialArgs = sharedArgs;
  };

  /*
  beta = mkNixosSystem {
    inherit withSystem;
    system = "x86_64-linux";
    modules = [
      ./beta
      server
    ]
    ++ concatLists [shared homes];
    specialArgs = sharedArgs;
  };

  lilith = mkNixosIso {
    system = "x86_64-linux";
    modules = [
      ./lilith
    ];
    specialArgs = sharedArgs;
  };
  */
}
