{ config, ... }:
{
  users.users.root = {
    inherit (config.users.users.${config.garden.system.mainUser}) hashedPassword;
  };
}
