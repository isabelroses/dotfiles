{ lib, config, ... }:
let
  inherit (lib) mkOption optionals types;
in
{
  config.warnings = optionals (config.modules.system.users == [ ]) [
    ''
      You have not added any users to be supported by your system. You may end up with an unbootable system!

      Consider setting {option}`config.modules.system.users` in your configuration
    ''
  ];

  options.modules.system = {
    mainUser = mkOption {
      type = types.enum config.modules.system.users;
      description = "The username of the main user for your system";
      default = builtins.elemAt config.modules.system.users 0;
    };

    users = mkOption {
      type = with types; listOf str;
      default = [ "isabel" ];
      description = ''
        A list of users that you wish to declare as your non-system users. The first username
        in the list will be treated as your main user unless `modules.system.mainUser` is set.
      '';
    };

    hostname = mkOption {
      type = types.str;
      description = "The name of the device for the system";
    };
  };
}
