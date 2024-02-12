{
  config.modules = {
    device = {
      type = "";
      cpu = "";
      gpu = null;
      monitors = [];
      hasTPM = true;
      hasBluetooth = true;
      hasSound = false;
    };

    system = {
      mainUser = "isabel";

      boot = {
        plymouth.enable = false;
        loader = "none";
        secureBoot = false;
        enableKernelTweaks = false;
        initrd.enableTweaks = false;
        loadRecommendedModules = false;
        tmpOnTmpfs = false;
      };

      fs = [];
      video.enable = true;
      sound.enable = true;
      bluetooth.enable = true;
      printing.enable = false;
      yubikeySupport.enable = true;

      security = {
        fixWebcam = false;
        auditd.enable = false;
      };

      networking = {
        optimizeTcp = true;

        wirelessBackend = "none";

        tailscale = {
          enable = false;
          isClient = false;
        };
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
      agnostic.git.signingKey = "7AFB9A49656E69F7";

      cli = {
        enable = true;
        modernShell.enable = true;
      };

      tui.enable = true;

      gui = {
        enable = true;

        kdeconnect.enable = false;

        terminals.wezterm.enable = true;

        zathura.enable = true;
      };

      defaults = {
        terminal = "wezterm";
      };
    };
  };
}
