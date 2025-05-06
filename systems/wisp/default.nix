{
  imports = [ ./users.nix ];

  garden = {
    profiles = {
      workstation.enable = true;
      headless.enable = true;
    };

    device = {
      cpu = null;
      gpu = null;
      hasTPM = true;
      monitors = [ ];
      hasBluetooth = true;
      keyboard = "us";
    };

    system = {
      boot = {
        loader = "none";
        secureBoot = false;
        tmpOnTmpfs = true;
        enableKernelTweaks = true;
        loadRecommendedModules = true;

        initrd = {
          enableTweaks = true;
          optimizeCompressor = true;
        };
      };

      bluetooth.enable = false;
      yubikeySupport.enable = false;

      security = {
        auditd.enable = true;
      };
    };

    environment.flakePath = "/mnt/d/dev/dotfiles";
  };
}
