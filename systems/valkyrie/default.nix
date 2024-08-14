{
  garden = {
    device = {
      type = "wsl";
      cpu = null;
      gpu = null;
      hasTPM = true;
      monitors = [ ];
      hasBluetooth = true;
      hasSound = false;
      keyboard = "us";
    };

    system = {
      mainUser = "isabel";

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

    environment = {
      desktop = null;
      useHomeManager = true;
    };

    programs = {
      agnostic.git.signingKey = "08A97B9A107A1798";

      cli = {
        enable = true;
        modernShell.enable = true;
      };

      tui.enable = true;
      gui.enable = false;
    };

    services.dev.vscode-server.enable = true;
  };
}
