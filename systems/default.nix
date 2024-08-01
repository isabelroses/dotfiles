{ inputs, ... }:
let
  inherit (inputs.self) lib;

  inherit (builtins) filter;
  inherit (lib.builders) mkSystems;
  inherit (lib.lists) concatLists;

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
  # for server type configurations
  server = [
    headless
    (hardwareProfilesPath + /server)
  ];
  # for wsl systems
  wsl = [
    headless
    (hardwareProfilesPath + /wsl)
  ];

  # meta profiles
  graphical = metaProfilesPath + /graphical; # for systems that have a graphical interface
  headless = metaProfilesPath + /headless; # for headless systems

  # home-manager
  homes = ../home; # home-manager configurations

  # a list of shared modules, that means they need to be in almost all configs
  shared = [
    base
    homes
  ];

  # This is a list of all the systems that exists on this flake
  # always edit this list rather then chaning nixosConfigurations or darwinConfigurations
  systems = [
    {
      host = "hydra";
      arch = "x86_64";
      target = "nixos";
      modules = [
        laptop
        graphical
      ] ++ concatLists [ shared ];
    }

    {
      host = "tatsumaki";
      arch = "aarch64";
      target = "darwin";
      modules = concatLists [ shared ];
    }

    {
      host = "amaterasu";
      arch = "x86_64";
      target = "nixos";
      modules = [
        desktop
        graphical
      ] ++ concatLists [ shared ];
    }

    {
      host = "valkyrie";
      arch = "x86_64";
      target = "nixos";
      modules = concatLists [
        wsl
        shared
      ];
    }

    {
      host = "luz";
      arch = "x86_64";
      target = "nixos";
      modules = concatLists [
        server
        shared
      ];
    }

    {
      host = "lilith";
      arch = "x86_64";
      target = "iso";
      modules = [ headless ];
    }
  ];
in
{
  flake = {
    darwinConfigurations = mkSystems (filter (x: x.target == "darwin") systems);
    nixosConfigurations = mkSystems (filter (x: x.target == "nixos" || x.target == "iso") systems);

    # NOTE: we redeclare the iso images here, such that they can easily be built
    # by the flake, with a short command `nix build .#images.lilith` for example
    # though you may prefer to use `nix-fast-build` for this
    images.lilith = inputs.self.nixosConfigurations.lilith.config.system.build.isoImage;
  };
}
