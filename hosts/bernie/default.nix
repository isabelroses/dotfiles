_: {
  imports = [
    ./hardware-configuration.nix
    ./mount.nix
    ./overrides.nix
    ./services.nix
  ];

  config.modules = {
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
      hostname = "bernie";

      boot = {
        loader = "grub";
        enableKernelTweaks = true;
        enableInitrdTweaks = true;
        loadRecommendedModules = true;
      };

      fs = ["vfat" "exfat" "ext4"];
      video.enable = false;
      sound.enable = false;
      bluetooth.enable = false;
      printing.enable = false;

      networking = {
        optimizeTcp = false;
      };

      virtualization = {
        enable = true;
        docker.enable = false;
        qemu.enable = false;
        podman.enable = false;
        distrobox.enable = false;
      };
    };
    usrEnv = {
      isWayland = false;
      useHomeManager = true;
    };

    programs = {
      git.signingKey = "B4D9D513B1560D99";

      cli = {
        enable = true;
        modernShell.enable = true;
      };
      tui.enable = true;
      gui.enable = false;
    };
  };
}
