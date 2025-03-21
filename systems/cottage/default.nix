{
  imports = [
    ./hardware.nix
    ./users.nix
  ];

  garden = {
    device = {
      profiles = [
        "laptop"
        "graphical"
      ];
      cpu = "amd";
      gpu = "amd";
      monitors = [ "eDP-1" ];
      hasTPM = true;
      hasBluetooth = true;
      hasSound = true;
    };

    system = {
      boot = {
        loader = "systemd-boot";
        secureBoot = true;
        tmpOnTmpfs = false;
        loadRecommendedModules = true;
        enableKernelTweaks = true;
        initrd.enableTweaks = true;
        plymouth.enable = false;
      };

      fs = {
        enableSwap = true;
        support = [
          "btrfs"
          "vfat"
        ];
      };

      video.enable = true;
      sound.enable = true;
      bluetooth.enable = true;
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
          isClient = false;
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

    style.font.name = "Maple Mono NF";
  };
}
