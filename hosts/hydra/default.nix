_: {
  imports = [./hardware-configuration.nix];
  config = {
    modules = {
      device = {
        type = "laptop";
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
          tmpOnTmpfs = true;
        };

        fs = ["btrfs" "vfat"];
        video.enable = true;
        sound.enable = true;
        bluetooth.enable = true;
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
            enable = true;
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
        agnostic.git.signingKey = "0xAE22E70709810C07";

        cli = {
          enable = true;
          modernShell.enable = true;
        };

        tui.enable = true;

        gui = {
          enable = true;

          kdeconnect = {
            enable = true;
            indicator.enable = true;
          };

          zathura.enable = true;
        };

        defaults = {
          bar = "ags";
        };
      };

      services.dev.vscode-server.enable = true;
    };

    boot = {
      kernelParams = [
        "nohibernate"
        "i915.enable_fbc=1"
        "i915.enable_psr=2"
      ];
    };

    console.earlySetup = true;
  };
}
