{
  lib,
  withSystem,
  ...
}: let
  inherit (lib) mkMerge concatLists mkSystems mkNixosIsos mapNodes;

  # modules
  modulePath = ../modules; # the base module path

  # base modules, is the base of this system configuration and are shared across all systems (so the basics)
  base = modulePath + /base;

  # profiles module, these are sensible defaults for given hardware sets
  # or meta profiles that are used to configure the system based on the requirements of the given machine
  profilesPath = modulePath + /profiles; # the base directory for the types module
  hardwareProfilesPath = profilesPath + /hardware; # the base directory for the hardware profiles
  metaProfilesPath = profilesPath + /meta; # the base directory for the meta profiles

  # hardware profiles
  laptop = hardwareProfilesPath + /laptop; # for laptop type configurations
  desktop = hardwareProfilesPath + /desktop; # for desktop type configurations
  server = [(hardwareProfilesPath + /server) headless]; # for server type configurations
  wsl = [(hardwareProfilesPath + /wsl) headless]; # for wsl systems

  # meta profiles
  workstation = metaProfilesPath + /workstation; # for server type configurations
  headless = metaProfilesPath + /headless; # for headless systems

  # home-manager
  homes = ../home; # home-manager configurations

  # a list of shared modules, that means they need to be in almost all configs
  shared = [base homes];

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
            desktop
            workstation
          ]
          ++ concatLists [shared];
        specialArgs = sharedArgs;
      }

      {
        host = "valkyrie";
        inherit withSystem;
        system = "x86_64-linux";
        modules = concatLists [wsl shared];
        specialArgs = sharedArgs;
      }

      {
        host = "luz";
        inherit withSystem;
        system = "x86_64-linux";
        modules = concatLists [server shared];
        specialArgs = sharedArgs;
      }

      {
        host = "tatsumaki";
        inherit withSystem;
        system = "aarch64-darwin";
        modules = concatLists [shared];
        specialArgs = sharedArgs;
      }
    ])

    (mkNixosIsos [
      {
        host = "lilith";
        system = "x86_64-linux";
        modules = [headless];
        specialArgs = sharedArgs;
      }
    ])

    {
      deploy = {
        remoteBuild = true;
        fastConnection = false;
        nodes = mapNodes ["luz"];
      };
    }
  ]
