{
  self,
  lib,
  withSystem,
  ...
}: let
  inherit (self) inputs;
  inherit (lib) mkMerge mapAttrs concatLists mkNixosSystem mkNixosIso;

  # home manager modules from inputs
  hm = inputs.home-manager.nixosModules.home-manager;
  cat = inputs.catppuccin.nixosModules.catppuccin;

  # modules
  modulePath = ../modules; # the base module path

  # base modules, are the basis of this system configuration and are shared across all systems
  baseModules = modulePath + /base; # the base directory for the common module
  common = baseModules + /common; # defaults for all systems
  options = baseModules + /options; # the module options for quick configuration

  # profiles are hardware based, system optimised defaults
  profilesModule = modulePath + /profiles; # the base directory for the types module
  server = profilesModule + /server; # for server type configurations
  laptop = profilesModule + /laptop; # for laptop type configurations
  desktop = profilesModule + /desktop; # for desktop type configurations
  workstation = profilesModule + /workstation; # for server type configurations

  # extra modules
  extraModules = modulePath + /extra; # the base directory for the extra module
  sharedModules = extraModules + /shared; # the base directory for the shared module

  # home-manager
  home = ../home; # home-manager configurations, used if hm is enabled
  homes = [hm home]; # combine hm input module and the home module, confiuration modules

  # a list of shared modules
  shared = [
    common # default shared across all system configuratons
    options # amazing quick settings module
    sharedModules # sharing is careing, this mainly contains: hm and nixos (if any) modules
    cat # catppucin for the quick themeing
  ];

  # extraSpecialArgs that are on all machines
  sharedArgs = {inherit inputs self lib;};
in
  mkMerge [
    (mapAttrs mkNixosSystem {
      # super rubbish laptop
      hydra = {
        inherit withSystem;
        system = "x86_64-linux";
        modules =
          [
            workstation
            laptop
          ]
          ++ concatLists [shared homes];
        specialArgs = sharedArgs;
      };

      # super cool gamer pc
      amatarasu = {
        inherit withSystem;
        system = "x86_64-linux";
        modules =
          [
            desktop
            workstation
          ]
          ++ concatLists [shared homes];
        specialArgs = sharedArgs;
      };

      # hertzner cloud computer
      luz = {
        inherit withSystem;
        system = "x86_64-linux";
        modules =
          [
            server
          ]
          ++ concatLists [shared homes];
        specialArgs = sharedArgs;
      };
    })

    (mapAttrs mkNixosIso {
      lilith = {
        system = "x86_64-linux";
        specialArgs = sharedArgs;
      };
    })
  ]
