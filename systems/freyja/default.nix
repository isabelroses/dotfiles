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

    system = {
      boot.loader = "systemd-boot";

      networking.useRouterDns = true;
    };

    services = {
      arr.enable = true;

      home-assistant = {
        enable = true;
        radio = "/dev/serial/by-id/usb-SONOFF_SONOFF_Dongle_Plus_MG24_a8ad9d6a37a1ef11b4e1976661ce3355-if00-port0";
      };

      immich = {
        enable = true;
        host = "0.0.0.0";
      };
      lethe = {
        enable = true;
        host = "0.0.0.0";
      };
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
