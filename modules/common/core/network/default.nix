{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  imports = [
    ./ssh.nix
    ./blocker.nix
  ];

  services = {
    # systemd DNS resolver daemon
    resolved.enable = true;
  };

  networking = {
    # dns
    nameservers = [
      # cloudflare, yuck
      # shares data
      "1.1.1.1"
      "1.0.0.1"

      # quad9, said to be the best
      # shares *less* data
      "9.9.9.9"
    ];

    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      unmanaged = ["docker0" "rndis0"];
      wifi = {
        powersave = true;
      };
    };
  };

  # slows down boot time
  systemd.services.NetworkManager-wait-online.enable = true;
  # enable wireless database
  hardware.wirelessRegulatoryDatabase = true;
}
