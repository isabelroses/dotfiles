{ inputs, ... }:
let
  inherit (inputs.self) lib;

  inherit (lib.modules) mkMerge;
  inherit (lib.builders) mkIsos mkSystems;
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
in
{
  flake = {
    darwinConfigurations = mkSystems [
      {
        host = "tatsumaki";
        system = "aarch64-darwin";
        modules = concatLists [ shared ];
      }
    ];

    nixosConfigurations = mkMerge [
      (mkSystems [
        {
          host = "hydra";
          system = "x86_64-linux";
          modules = [
            laptop
            graphical
          ] ++ concatLists [ shared ];
        }

        {
          host = "amaterasu";
          system = "x86_64-linux";
          modules = [
            desktop
            graphical
          ] ++ concatLists [ shared ];
        }

        {
          host = "valkyrie";
          system = "x86_64-linux";
          modules = concatLists [
            wsl
            shared
          ];
        }

        {
          host = "luz";
          system = "x86_64-linux";
          modules = concatLists [
            server
            shared
          ];
        }
      ])

      (mkIsos [
        {
          host = "lilith";
          system = "x86_64-linux";
          modules = [ headless ];
        }
      ])
    ];

    images.lilith = inputs.self.nixosConfigurations.lilith.config.system.build.isoImage;

    # TODO: move to parts/programs
    #
    # deploy = {
    #   autoRollback = mkDefault true;
    #   magicRollback = mkDefault true;
    #
    #   nodes.${args.host} = {
    #     hostname = args.host;
    #     skipChecks = true;
    #     sshUser = "isabel";
    #     user = "root";
    #     profiles.system.path =
    #       inputs.deploy-rs.lib.${system}.activate.nixos
    #         inputs.self.nixosConfigurations.${args.host};
    #   };
    # };
  };
}
