{
  imports = [
    ./hardware.nix
    ./users.nix
  ];

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";

  garden = {
    profiles = {
      laptop.enable = true;
      graphical.enable = true;
      workstation.enable = true;
    };

    device = {
      cpu = "amd";
      gpu = null;
      monitors = [
        "eDP-1"
        "HDMI-A-1"
      ];
      keyboard = "us";
      capabilities = {
        tpm = true;
        bluetooth = true;
      };
    };

    system = {
      boot = {
        loader = "systemd-boot";
        secureBoot = false;
        enableKernelTweaks = true;
        loadRecommendedModules = true;

        initrd = {
          enableTweaks = true;
          optimizeCompressor = true;
        };
      };

      bluetooth.enable = true;
      printing.enable = true;

      security = {
        fixWebcam = false;
        auditd.enable = true;
      };

      networking = {
        optimizeTcp = true;
        wirelessBackend = "iwd";
      };
    };
  };
}
