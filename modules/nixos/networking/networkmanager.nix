{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf mkForce;
  inherit (lib.lists) optionals;

  dev = config.garden.device;
  sys = config.garden.system;
in
{
  environment.systemPackages = optionals config.garden.meta.gui [
    pkgs.networkmanagerapplet # provides nm-connection-editor
  ];

  networking.networkmanager = {
    enable = true;
    plugins = mkForce (optionals config.garden.meta.gui [ pkgs.networkmanager-openvpn ]);
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
      # this can be iwd or wpa_supplicant, use wpa_s until iwd support is stable
      backend = sys.networking.wirelessBackend;

      # The below is disabled as my uni hated me for it
      # macAddress = "random"; # use a random mac address on every boot, this can scew with static ip
      powersave = true;

      # MAC address randomization of a Wi-Fi device during scanning
      scanRandMacAddress = true;
    };

    # causes server to be unreachable over SSH
    ethernet.macAddress = mkIf (dev.type != "server") "random";
  };
}
