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
      cloudflared.enable = true;
      arr.enable = true;

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
}
