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
    #  modules = [ ];
    #  specialArgs = { };
    hosts = {
      # isabel's hosts
      # keep-sorted start block=yes newline_separated=yes
      amaterasu = { };

      athena = { };

      hestia = { };

      lilith = {
        class = "iso";
      };

      minerva = { };

      skadi = {
        arch = "aarch64";
      };

      tatsumaki = {
        arch = "aarch64";
        class = "darwin";
      };

      valkyrie = {
        class = "wsl";
      };
      # keep-sorted end

      # robin's hosts
      # keep-sorted start block=yes newline_separated=yes
      bmo = { };

      cottage = { };

      wisp = {
        class = "wsl";
      };
      # keep-sorted end
    };
  };
}
