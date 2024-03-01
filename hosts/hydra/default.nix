{
  imports = [./hardware.nix];

  config.modules = {
    device = {
      type = "hybrid";
      cpu = "intel";
      gpu = null;
      monitors = ["eDP-1"];
      hasTPM = true;
      hasBluetooth = true;
      hasSound = true;
    };

    system = {
      mainUser = "isabel";

      boot = {
        plymouth.enable = false;
        loader = "systemd-boot";
        secureBoot = false;
        enableKernelTweaks = true;
        initrd.enableTweaks = true;
        loadRecommendedModules = true;
        tmpOnTmpfs = false;
      };

      fs = ["btrfs" "vfat"];
      video.enable = true;
      sound.enable = true;
      bluetooth.enable = false;
      printing.enable = false;
      yubikeySupport.enable = true;

      security = {
        fixWebcam = false;
        auditd.enable = true;
      };

      networking = {
        optimizeTcp = true;

        wirelessBackend = "iwd";

        tailscale = {
          enable = false;
          isClient = true;
        };
      };

      virtualization = {
        enable = true;
        docker.enable = true;
        qemu.enable = false;
        podman.enable = false;
        distrobox.enable = false;
      };
    };

    environment = {
      desktop = "Hyprland";
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

        kdeconnect = {
          enable = false;
          indicator.enable = true;
        };

        zathura.enable = true;
      };
    };

    services.dev.vscode-server.enable = true;
  };
}
