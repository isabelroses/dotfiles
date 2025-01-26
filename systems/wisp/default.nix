{
  imports = [ ./users.nix ];

  garden = {
    device = {
      cpu = null;
      gpu = null;
      hasTPM = true;
      monitors = [ ];
      hasBluetooth = true;
      hasSound = false;
      keyboard = "us";
    };

    system = {
      boot = {
        loader = "none";
        secureBoot = false;
        tmpOnTmpfs = true;
        enableKernelTweaks = true;
        loadRecommendedModules = true;
        plymouth.enable = false;

        initrd = {
          enableTweaks = true;
          optimizeCompressor = true;
        };
      };

      fs.support = [
        "ext4"
        "vfat"
      ];
      video.enable = false;
      sound.enable = false;
      bluetooth.enable = false;
      yubikeySupport.enable = false;

      security = {
        auditd.enable = true;
      };

      networking = {
        optimizeTcp = true;
      };

      virtualization = {
        enable = false;
        docker.enable = false;
        qemu.enable = false;
        podman.enable = false;
        distrobox.enable = false;
      };
    };
  };
}
