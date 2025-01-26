{
  imports = [
    ./hardware.nix
    ./users.nix
  ];

  garden = {
    device = {
      cpu = "intel";
      gpu = "nvidia";
      hasTPM = true;
      monitors = [ "DP-1" ];
      hasBluetooth = true;
      hasSound = true;
      keyboard = "us";
    };

    system = {
      boot = {
        loader = "systemd-boot";
        secureBoot = true;
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
        "ntfs"
      ];
      video.enable = true;
      sound.enable = true;
      bluetooth.enable = false;
      printing.enable = false;
      yubikeySupport.enable = true;
      emulation.enable = true;

      security.auditd.enable = true;

      networking = {
        optimizeTcp = true;
        wirelessBackend = "iwd";
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
