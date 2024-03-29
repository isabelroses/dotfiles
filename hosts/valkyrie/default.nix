{
  config = {
    modules = {
      device = {
        type = "wsl";
        cpu = "intel";
        gpu = null;
        hasTPM = true;
        monitors = [];
        hasBluetooth = true;
        hasSound = false;
        keyboard = "us";
      };

      system = {
        mainUser = "isabel";

        boot = {
          loader = "none";
          secureBoot = false;
          plymouth = {
            enable = false;
            withThemes = true;
          };
          enableKernelTweaks = true;
          initrd = {
            enableTweaks = true;
            optimizeCompressor = true;
          };
          loadRecommendedModules = true;
          tmpOnTmpfs = true;
        };

        fs = ["ext4" "vfat"];
        video.enable = false;
        sound.enable = false;
        bluetooth.enable = false;
        printing.enable = false;
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
    };
  };
}
