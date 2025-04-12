{
  lib,
  self,
  inputs,
  ...
}:
let
  inherit (lib.lists) optionals concatLists;
in
{
  imports = [ inputs.easy-hosts.flakeModule ];

  config.easy-hosts = {
    additionalClasses = {
      wsl = "nixos";
    };

    perClass = class: {
      modules = concatLists [
        [
          # import the class module, this contains the common configurations between all systems of the same class
          "${self}/modules/${class}/default.nix"
        ]

        (optionals (class != "iso") [
          # import the home module, which is users for configuring users via home-manager
          "${self}/home/default.nix"

          # import the base module, this contains the common configurations between all systems
          "${self}/modules/base/default.nix"
        ])
      ];
    };

    # This is the list of system configuration
    #
    # the defaults consists of the following:
    #  arch = "x86_64";
    #  class = "nixos";
    #  deployable = false;
    #  modules = [ ];
    #  specialArgs = { };
    hosts = {
      # isabel's hosts
      hydra = { };

      tatsumaki = {
        arch = "aarch64";
        class = "darwin";
      };

      amaterasu = { };

      valkyrie = {
        class = "wsl";
      };

      minerva = {
        deployable = true;
      };

      hestia = {
        deployable = true;
      };

      skadi = {
        arch = "aarch64";
        deployable = true;
      };

      lilith = {
        class = "iso";
      };

      # robin's hosts
      cottage = { };

      # bmo = { };

      wisp = {
        class = "wsl";
      };
    };
  };
}
