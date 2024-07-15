{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (config.garden) device;
in
{
  # enable opportunistic TCP encryption
  # this is NOT a pancea, however, if the receiver supports encryption and the attacker is passive
  # privacy will be more plausible (but not guaranteed, unlike what the option docs suggest)
  networking.tcpcrypt.enable = device.type != "server";

  users = mkIf config.networking.tcpcrypt.enable {
    groups.tcpcryptd = { };
    users.tcpcryptd = {
      group = "tcpcryptd";
      isSystemUser = true;
    };
  };
}
