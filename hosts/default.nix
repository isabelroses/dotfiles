{
  self,
  lib,
  withSystem,
  ...
}: let
  inherit (lib) mkMerge concatLists mkSystems mkNixosIsos;

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
  homes = ../home; # home-manager configurations

  # a list of shared modules
  shared = [base options extra homes];

  # extra specialArgs that are on all machines
  sharedArgs = {inherit lib;};
in
  mkMerge [
    (mkSystems [
      {
        host = "hydra";
        inherit withSystem;
        system = "x86_64-linux";
        modules =
          [
            workstation
            laptop
          ]
          ++ concatLists [shared];
        specialArgs = sharedArgs;
      }

      {
        host = "amaterasu";
        inherit withSystem;
        system = "x86_64-linux";
        modules =
          [
            # desktop
            workstation
          ]
          ++ concatLists [shared];
        specialArgs = sharedArgs;
      }

      {
        host = "valkyrie";
        inherit withSystem;
        system = "x86_64-linux";
        modules = [wsl] ++ concatLists [shared];
        specialArgs = sharedArgs;
      }

      {
        host = "luz";
        inherit withSystem;
        system = "x86_64-linux";
        modules = [server] ++ concatLists [shared];
        specialArgs = sharedArgs;
      }
    ])

    (mkNixosIsos [
      {
        host = "lilith";
        system = "x86_64-linux";
        type = "iso";
        specialArgs = sharedArgs;
      }
    ])
  ]
