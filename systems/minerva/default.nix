{
  imports = [
    ./hardware.nix
    ./overrides.nix
    ./services.nix
    ./networking.nix
  ];

  garden = {
    device = {
      type = "server";
      cpu = "amd";
      gpu = null;
      hasTPM = false;
      hasBluetooth = false;
      hasSound = false;
    };

    system = {
      mainUser = "isabel";

      boot = {
        loader = "grub";
        enableKernelTweaks = true;
        initrd.enableTweaks = true;
        loadRecommendedModules = true;
        tmpOnTmpfs = false;
      };

      fs.support = [
        "vfat"
        "exfat"
        "ext4"
      ];
      video.enable = false;
      sound.enable = false;
      bluetooth.enable = false;

      networking = {
        optimizeTcp = false;

        tailscale = {
          enable = true;
          isServer = true;
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
      agnostic.git.signingKey = "7F2F6BD6997FCDF7";

      cli = {
        enable = true;
        modernShell.enable = true;
      };

      tui.enable = true;
      gui.enable = false;
    };
  };
}
