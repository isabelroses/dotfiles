{
  imports = [
    ./hardware.nix
    ./users.nix
  ];

  garden = {
    device = {
      profiles = [
        "server"
        "laptop"
        "graphical"
      ];
      cpu = "intel";
      gpu = null;
      monitors = [ "eDP-1" ];
      hasTPM = true;
      hasBluetooth = true;
      hasSound = true;
    };

    system = {
      boot = {
        loader = "systemd-boot";
        secureBoot = false;
        tmpOnTmpfs = false;
        loadRecommendedModules = true;
        enableKernelTweaks = true;
        initrd.enableTweaks = true;
        plymouth.enable = false;
      };

      fs.support = [
        "btrfs"
        "vfat"
      ];
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
  };
}
