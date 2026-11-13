{ lib, ... }:
{
  imports = [
    ./hardware.nix
  ];

  garden = {
    profiles = {
      server.enable = true;
      headless.enable = true;
    };

    device = {
      cpu = "amd";
      gpu = "nvidia";
      capabilities = {
        tpm = true;
      };
    };

    system.boot.loader = "systemd-boot";

    services = {
      arr.enable = true;

      home-assistant = {
        enable = true;
        # set to the dongle's /dev/serial/by-id path once it's flashed to
        # thread firmware to bring up the border router
        # radio = "/dev/serial/by-id/...";
      };

      immich = {
        enable = true;
        host = "0.0.0.0";
      };
      qbittorrent.host = "0.0.0.0";
      borgbackup = {
        enable = true;
        jobs.postgresql.enable = false;
      };
    };
  };

  services.smartd.enable = lib.modules.mkForce false;

  # where to advertise the thread mesh, only used once the radio is set
  services.openthread-border-router.backboneInterfaces = [ "enp6s0" ];
}
