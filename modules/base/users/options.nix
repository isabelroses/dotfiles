{
  lib,
  pkgs,
  self,
  self',
  config,
  _class,
  inputs,
  inputs',
  ...
}:
let
  inherit (lib.options) mkOption;
  inherit (lib.lists) optional;
  inherit (lib.types) enum attrsOf submoduleWith;
  inherit (lib.attrsets) attrNames;

  hm = submoduleWith {
    description = "meow";
    class = "homeManager";
    specialArgs = {
      inherit self inputs;
      modulesPath = builtins.toString (self + "/modules/home");
    };
    modules = [
      (self + "/modules/home")

      {
        _module.args = {
          inherit pkgs self' inputs';
          osConfig = config;
          osClass = _class;
        };
      }

      (
        { name, ... }:
        {
          home = {
            username = config.users.users.${name}.name;
            homeDirectory = config.users.users.${name}.home;
          };
        }
      )
    ];
  };
in
{
  options.garden = {
    system.mainUser = mkOption {
      type = enum (attrNames config.garden.users);
      description = "The username of the main user for your system";
      default = builtins.elemAt config.garden.users 0;
    };

    users = mkOption {
      type = attrsOf hm;
      default = { };
      description = ''
        A list of users that you wish to declare as your non-system users. The first username
        in the list will be treated as your main user unless {option}`garden.system.mainUser` is set.
      '';
    };
  };

  config.warnings = optional (config.garden.users == { }) ''
    You have not added any users to be supported by your system. You may end up with an unbootable system!

    Consider setting {option}`config.garden.users` in your configuration
  '';
}
