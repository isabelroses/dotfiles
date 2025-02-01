{
  imports = [
    ./hardware.nix
    ./users.nix
  ];

  garden = {
    device = {
      cpu = "amd";
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
        enableKernelTweaks = true;
        loadRecommendedModules = true;
        plymouth.enable = false;

        initrd = {
          enableTweaks = true;
          optimizeCompressor = true;
        };
      };

      fs.support = [
        "btrfs"
        "vfat"
      ];
      video.enable = true;
      sound.enable = true;
      bluetooth.enable = false;
      printing.enable = false;
      yubikeySupport.enable = false;

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
        docker.enable = false;
        qemu.enable = false;
        podman.enable = false;
        distrobox.enable = false;
      };
    };
  };
}
