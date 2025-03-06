{ config, ... }:
{
  system.primaryUser = config.garden.system.mainUser;
}
