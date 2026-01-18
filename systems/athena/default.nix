{ lib, ... }:
{
  imports = [ ./hardware.nix ];

  garden = {
    profiles = {
      server.enable = true;
      laptop.enable = true;
      headless.enable = true;
    };

    device = {
      cpu = "intel";
      gpu = "intel";
      monitors.eDP-1 = { };
      keyboard = "us";
      capabilities = {
        tpm = true;
        bluetooth = true;
      };
    };

    system.boot = {
      loader = "systemd-boot";
      secureBoot = false;
      loadRecommendedModules = true;
      enableKernelTweaks = true;
      initrd.enableTweaks = true;
    };

    services = {
      cloudflared.enable = true;
      immich.enable = true;
      arr.enable = true;
      borgbackup.enable = true;
      glance.enable = true;
    };
  };

  services.smartd.enable = lib.mkForce false;
}
