{lib, ...}:
with lib; {
  imports = [
    ./blocker.nix
    ./firewall.nix
    ./ssh.nix
    ./optimise.nix
  ];

  services = {
    # systemd DNS resolver daemon
    resolved.enable = true;
  };

  networking = {
    # use dhcpd
    useDHCP = mkDefault false;
    useNetworkd = mkDefault true;

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
      plugins = [];
      dns = "systemd-resolved";
      unmanaged = ["docker0" "rndis0"];
      wifi = {
        powersave = true;
      };
    };
  };

  # enable wireless database
  hardware.wirelessRegulatoryDatabase = true;

  # slows down boot time
  systemd.services.NetworkManager-wait-online.enable = true;
  systemd.network.wait-online.enable = false;
  systemd.services.systemd-networkd.stopIfChanged = false;
  systemd.services.systemd-resolved.stopIfChanged = false;
}
