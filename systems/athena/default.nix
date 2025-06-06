{
  imports = [
    ./hardware.nix
    ./users.nix
  ];

  garden = {
    profiles = {
      server.enable = true;
      laptop.enable = true;
      graphical.enable = true;
      workstation.enable = true;
    };

    programs.cosmic.enable = true;

    device = {
      cpu = "intel";
      gpu = null;
      monitors = [ "eDP-1" ];
      capabilities = {
        tpm = true;
        bluetooth = true;
        yubikey = true;
      };
    };

    system = {
      boot = {
        loader = "systemd-boot";
        secureBoot = false;
        loadRecommendedModules = true;
        enableKernelTweaks = true;
        initrd.enableTweaks = true;
      };

      bluetooth.enable = false;
      printing.enable = false;

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
