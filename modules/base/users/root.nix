{
  lib,
  _class,
  config,
  ...
}:
{
  users.users.root = lib.mkIf (_class == "nixos") {
    inherit (config.users.users.${config.garden.system.mainUser}) hashedPassword;
  };
}
