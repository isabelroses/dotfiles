{
  self,
  lib,
  withSystem,
  ...
}: let
  inputs = self.inputs;
  inherit (lib) concatLists mkNixosSystem;

  # common modules, to be shared across all systems
  commonModules = ../modules/common; # the path where common modules reside
  core = commonModules + /core; # the self-proclaimed sane defaults for all my systems
  system = commonModules + /system; # system module for configuring system-specific options easily
  options = commonModules + /options; # the module that provides the options for my system configuration

  # extra modules, likely optional but possibly critical
  extraModules = ../modules/extra; # the path where extra modules reside
  #server = extraModules + /server; # for devices that act as "servers"
  desktop = extraModules + /desktop; # for devices that are for daily use
  virtualization = extraModules + /virtualization; # hotpluggable virtalization module

  ## home-manager ##
  home = ../home; # home-manager configurations for hosts that need home-manager
  homes = [hm home]; # combine hm flake input and the home module to be imported together

  ## flake inputs ##
  hm = inputs.home-manager.nixosModules.home-manager; # home-manager nixos module
  cat = inputs.catppuccin.nixosModules.catppuccin;

  # a list of shared modules that ALL systems need
  shared = [
    system # the skeleton module for config.modules.*
    core # the "sane" default shared across systems
    options
    cat # for the quick themeing
  ];

  # extraSpecialArgs that all hosts need
  sharedArgs = {inherit inputs self lib;};
in {
  # fuck nvidia - Linus "the linux" Torvalds
  amatarasu = mkNixosSystem {
    inherit withSystem;
    system = "x86_64-linux";
    modules =
      [
        {networking.hostName = "amatarasu";}
        ./amatarasu
        desktop
        virtualization
      ]
      ++ concatLists [shared homes];
    specialArgs = sharedArgs;
  };

  hydra = mkNixosSystem {
    inherit withSystem;
    system = "x86_64-linux";
    modules =
      [
        {networking.hostName = "hydra";}
        ./hydra
        desktop
        virtualization
      ]
      ++ concatLists [shared homes];
    specialArgs = sharedArgs;
  };
}
