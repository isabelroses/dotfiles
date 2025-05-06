{ self, inputs, ... }:
{
  imports = [ inputs.easy-hosts.flakeModule ];

  config.easy-hosts = {
    additionalClasses = {
      wsl = "nixos";
    };

    perClass = class: {
      modules = [
        # import the class module, this contains the common configurations between all systems of the same class
        "${self}/modules/${class}/default.nix"
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
      amaterasu = { };
      athena = { };

      tatsumaki = {
        arch = "aarch64";
        class = "darwin";
      };

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
