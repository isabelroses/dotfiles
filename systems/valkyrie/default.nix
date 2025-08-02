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
      monitors = [ ];
      capabilities = {
        tpm = true;
        bluetooth = false;
      };
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

      emulation.enable = true;

      bluetooth.enable = false;
      security.auditd.enable = true;
    };
  };
}
