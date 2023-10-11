{
  self,
  lib,
  withSystem,
  ...
}: let
  inherit (self) inputs;
  inherit (lib) concatLists mkNixosSystem mkNixosIso;

  # home manager modules from inputs
  hm = inputs.home-manager.nixosModules.home-manager;
  cat = inputs.catppuccin.nixosModules.catppuccin;

  # modules
  modulePath = ../modules; # the base module path
  options = modulePath + /options; # the module options for quick configuration

  # common modules, these are shared across all systems
  commonModules = modulePath + /common; # the base directory for the common module
  core = commonModules + /core; # defaults for all systems
  secrets = commonModules + /secrets; # shhh

  # hardware types, providing improved defaults and system preformance improvements
  deviceType = commonModules + /types; # the base directory for the types module
  server = deviceType + /server; # for server type configurations
  laptop = deviceType + /laptop; # for laptop type configurations
  desktop = deviceType + /desktop; # for desktop type configurations
  workstation = deviceType + /workstation; # for server type configurations
  #hybrid = [server laptop]; # combine the server and laptop configurations for the best of both worlds

  # extra modules
  extraModules = modulePath + /extra; # the base directory for the extra module
  sharedModules = extraModules + /shared; # the base directory for the shared module

  ## home-manager
  home = ../home; # home-manager configurations, used if hm is enabled
  homes = [hm home]; # combine hm input module and the home module, confiuration modules

  # a list of shared modules
  shared = [
    core # default shared across all system configuratons
    options # amazing quick settings module
    sharedModules # sharing is careing, this mainly contains: hm and nixos (if any) modules
    cat # catppucin for the quick themeing
    secrets # shh
  ];

  # extraSpecialArgs that are on all machines
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
  */

  lilith = mkNixosIso {
    system = "x86_64-linux";
    modules = [
      ./lilith
    ];
    specialArgs = sharedArgs;
  };
}
