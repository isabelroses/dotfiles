{
  self,
  lib,
  withSystem,
  ...
}: let
  inputs = self.inputs;

  commonModules = ../modules/common; # the path where common modules reside
  extraModules = ../modules/extra; # the path where extra modules reside

  # common modules, to be shared across all systems
  core = commonModules + /core; # the self-proclaimed sane defaults for all my systems
  system = commonModules + /system; # system module for configuring system-specific options easily
  options = commonModules + /options; # the module that provides the options for my system configuration

  # extra modules, likely optional but possibly critical
  #server = extraModules + /server; # for devices that act as "servers"
  desktop = extraModules + /desktop; # for devices that are for daily use
  virtualization = extraModules + /virtualization; # hotpluggable virtalization module

  # profiles
  profiles = ../modules + /profiles;

  ## home-manager ##
  home = ../home; # home-manager configurations for hosts that need home-manager
  homes = [hm home]; # combine hm flake input and the home module to be imported together

  ## flake inputs ##
  hm = inputs.home-manager.nixosModules.home-manager; # home-manager nixos module
  cat = inputs.catppuccin.nixosModules.catppuccin; # cattpuccin nixos module

  # a list of shared modules that ALL systems need
  shared = [
    system # the skeleton module for config.modules.*
    core # the "sane" default shared across systems
    profiles # a profiles module to provide configuration sets per demand
    options
    cat
  ];

  # extraSpecialArgs that all hosts need
  sharedArgs = {inherit inputs self lib;};
in {
  # fuck nvidia - Linus "the linux" Torvalds
  amatarasu = lib.mkNixosSystem {
    inherit withSystem;
    system = "x86_64-linux";
    modules =
      [
        {networking.hostName = "amatarasu";}
        ./amatarasu
        desktop
        virtualization
      ]
      ++ lib.concatLists [shared homes];
    specialArgs = sharedArgs;
  };

  hydra = lib.mkNixosSystem {
    inherit withSystem;
    system = "x86_64-linux";
    modules =
      [
        {networking.hostName = "hydra";}
        ./hydra
        desktop
        virtualization
      ]
      ++ lib.concatLists [shared homes];
    specialArgs = sharedArgs;
  };
}
