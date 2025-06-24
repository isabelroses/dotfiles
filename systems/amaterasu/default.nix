{
  imports = [
    ./hardware.nix
    ./users.nix
  ];

  garden = {
    profiles = {
      graphical.enable = true;
      workstation.enable = true;
    };

    device = {
      cpu = "intel";
      gpu = "nvidia";
      monitors = [ "DP-1" ];
      capabilities = {
        tpm = true;
        bluetooth = true;
        yubikey = true;
      };
      keyboard = "us";
    };

    system = {
      boot = {
        loader = "systemd-boot";
        secureBoot = true;
        enableKernelTweaks = true;
        loadRecommendedModules = true;

        initrd = {
          enableTweaks = true;
          optimizeCompressor = true;
        };
      };

      bluetooth.enable = false;
      printing.enable = false;
      emulation.enable = true;

      security.auditd.enable = true;

      networking = {
        optimizeTcp = true;
        wirelessBackend = "iwd";
      };
    };
  };
}
