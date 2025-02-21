{
  imports = [
    ./hardware.nix
    ./overrides.nix
    ./services.nix
    ./networking.nix
    ./users.nix
  ];

  garden = {
    device = {
      cpu = "intel";
      gpu = null;
      hasTPM = false;
      hasBluetooth = false;
      hasSound = false;
    };

    system = {
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
          enable = false;
          isServer = false;
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
  };
}
