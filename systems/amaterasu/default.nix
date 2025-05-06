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
      hasTPM = true;
      monitors = [ "DP-1" ];
      hasBluetooth = true;
      keyboard = "us";
    };

    programs.cosmic.enable = true;

    system = {
      boot = {
        loader = "systemd-boot";
        secureBoot = true;
        tmpOnTmpfs = true;
        enableKernelTweaks = true;
        loadRecommendedModules = true;

        initrd = {
          enableTweaks = true;
          optimizeCompressor = true;
        };
      };

      bluetooth.enable = false;
      printing.enable = false;
      yubikeySupport.enable = true;
      emulation.enable = true;

      security.auditd.enable = true;

      networking = {
        optimizeTcp = true;
        wirelessBackend = "iwd";
      };
    };
  };
}
