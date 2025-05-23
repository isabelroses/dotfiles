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
      hasBluetooth = false;
      keyboard = "us";
    };

    system = {
      boot = {
        loader = "none";
        secureBoot = false;
        enableKernelTweaks = true;
        loadRecommendedModules = true;

        initrd = {
          enableTweaks = true;
          optimizeCompressor = true;
        };
      };

      bluetooth.enable = false;
      yubikeySupport.enable = false;
      security.auditd.enable = true;
    };
  };
}
