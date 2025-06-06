{
  imports = [
    ./hardware.nix
    ./users.nix
  ];

  garden = {
    profiles = {
      laptop.enable = true;
      graphical.enable = true;
      workstation.enable = true;
    };

    device = {
      cpu = "amd";
      gpu = "amd";
      monitors = [ "eDP-1" ];
      capabilities = {
        tpm = true;
        bluetooth = true;
      };
    };

    system = {
      boot = {
        loader = "systemd-boot";
        secureBoot = true;
        loadRecommendedModules = true;
        enableKernelTweaks = true;
        initrd.enableTweaks = true;
      };

      bluetooth.enable = true;
      printing.enable = false;

      security = {
        fixWebcam = false;
        auditd.enable = true;
      };

      networking = {
        optimizeTcp = true;

        wirelessBackend = "iwd";

        tailscale = {
          enable = false;
          isClient = false;
        };
      };
    };
  };
}
