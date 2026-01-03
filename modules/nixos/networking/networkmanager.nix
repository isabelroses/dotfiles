{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) optionalAttrs;
in
{
  garden.packages = optionalAttrs config.garden.profiles.graphical.enable {
    inherit (pkgs) networkmanagerapplet; # provides nm-connection-editor
  };

  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    unmanaged = [
      "interface-name:tailscale*"
      "interface-name:br-*"
      "interface-name:rndis*"
      "interface-name:docker*"
      "interface-name:virbr*"
      "interface-name:vboxnet*"
      "interface-name:waydroid*"
      "type:bridge"
    ];

    wifi = {
      # this can be iwd or wpa_supplicant
      backend = "iwd";
      powersave = true;

      # The below is disabled as my uni hated me for it
      # use a random mac address on every boot, this can scew with static ip
      # macAddress = "random";

      # MAC address randomization of a Wi-Fi device during scanning
      scanRandMacAddress = true;
    };

    # causes server to be unreachable over SSH
    # ethernet.macAddress = mkIf (!config.garden.profiles.server.enable) "random";
  };
}
