{
  self,
  lib,
  withSystem,
  ...
}: let
  inherit (self) inputs;
  inherit (lib) mkMerge mapAttrs concatLists mkNixosSystem mkNixosIso;

  # additional modules
  hm = inputs.home-manager.nixosModules.home-manager;
  ctp = inputs.catppuccin.nixosModules.catppuccin;

  # modules
  modulePath = ../modules; # the base module path

  # base modules, are the base of this system configuration and are shared across all systems (so the basics)
  base = modulePath + /base;

  # extra modules, these add extra functionality to the system configuration, not provided by nixpkgs or another source
  extra = modulePath + /extra;

  # options module, these allow for quick configuration
  options = modulePath + /options;

  # profiles are hardware based, system optimised defaults
  profilesPath = modulePath + /profiles; # the base directory for the types module
  server = profilesPath + /server; # for server type configurations
  laptop = profilesPath + /laptop; # for laptop type configurations
  # desktop = profilesPath + /desktop; # for desktop type configurations
  workstation = profilesPath + /workstation; # for server type configurations
  wsl = profilesPath + /wsl; # for wsl systems

  # home-manager
  home = ../home; # home-manager configurations
  homes = [hm home]; # combine hm input module and the home module

  # a list of shared modules
  shared = [base options extra ctp];

  # extra specialArgs that are on all machines
  sharedArgs = {inherit inputs self lib;};
in
  mkMerge [
    (mapAttrs mkNixosSystem {
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

      amaterasu = {
        inherit withSystem;
        system = "x86_64-linux";
        modules =
          [
            # desktop
            workstation
          ]
          ++ concatLists [shared homes];
        specialArgs = sharedArgs;
      };

      valkyrie = {
        inherit withSystem;
        system = "x86_64-linux";
        modules = [wsl] ++ concatLists [shared homes];
        specialArgs = sharedArgs;
      };

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
