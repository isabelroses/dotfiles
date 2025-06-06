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
        bluetooth = true;
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

      bluetooth.enable = false;

      security = {
        auditd.enable = true;
      };
    };

    environment.flakePath = "/mnt/d/dev/dotfiles";
  };
}
