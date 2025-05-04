{ lib, config, ... }:
let
  inherit (lib.options) mkOption;
in
{
  options = {
    home = {
      username = mkOption {
        type = lib.types.str;
        default = "isabel";
        description = ''
          The username of the main user for your system.
        '';
      };

      homeDirectory = mkOption {
        type = lib.types.path;
        default = "/home/${config.home.username}";
        description = ''
          The home directory of the main user for your system.
        '';
      };
    };
  };
}
