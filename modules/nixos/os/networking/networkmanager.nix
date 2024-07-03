{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkForce;

  dev = config.garden.device;
  sys = config.garden.system;
in
{
  environment.systemPackages = with pkgs; [ networkmanagerapplet ];

  networking.networkmanager = {
    enable = true;
    plugins = mkForce [ pkgs.networkmanager-openvpn ];
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
      backend = sys.networking.wirelessBackend; # this can be iwd or wpa_supplicant, use wpa_s until iwd support is stable
      # The below is disabled as my uni hated me for it
      # macAddress = "random"; # use a random mac address on every boot, this can scew with static ip
      powersave = true;
      scanRandMacAddress = true; # MAC address randomization of a Wi-Fi device during scanning
    };

    ethernet.macAddress = mkIf (dev.type != "server") "random"; # causes server to be unreachable over SSH
  };
}
