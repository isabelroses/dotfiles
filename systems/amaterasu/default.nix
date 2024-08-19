{
  imports = [ ./hardware.nix ];

  garden = {
    device = {
      type = "desktop";
      cpu = "intel";
      gpu = "nvidia";
      hasTPM = true;
      monitors = [ "DP-1" ];
      hasBluetooth = true;
      hasSound = true;
      keyboard = "us";
    };

    system = {
      mainUser = "isabel";

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

      networking.optimizeTcp = true;

      virtualization = {
        enable = false;
        docker.enable = false;
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
      agnostic.git.signingKey = "7F2F6BD6997FCDF7";

      cli = {
        enable = true;
        modernShell.enable = true;
      };

      tui.enable = true;

      gui = {
        enable = true;

        discord.enable = true;
        zathura.enable = true;

        terminals = {
          wezterm.enable = true;
          ghostty.enable = false;
          alacritty.enable = false;
        };

        browsers = {
          chromium.enable = true;
          firefox.enable = false;
        };
      };
    };
  };
}
