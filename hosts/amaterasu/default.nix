{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkForce optionals;
  inherit (config.modules) device;
in {
  imports = [./hardware-configuration.nix];
  config = {
    modules = {
      device = {
        type = "desktop";
        cpu = "intel";
        gpu = "nvidia";
        hasTPM = true;
        monitors = ["HDMI-1" "DP-1"];
        hasBluetooth = true;
        hasSound = true;
        keyboard = "us";
      };
      system = {
        mainUser = "isabel";

        boot = {
          loader = "systemd-boot";
          secureBoot = false;
          plymouth = {
            enable = true;
            withThemes = true;
          };
          enableKernelTweaks = true;
          initrd = {
            enableTweaks = true;
            optimizeCompressor = true;
          };
          loadRecommendedModules = true;
        };

        fs = ["ext4" "vfat"];
        video.enable = true;
        sound.enable = true;
        bluetooth.enable = false;
        printing.enable = false;
        yubikeySupport.enable = true;

        security = {
          auditd.enable = true;
        };

        networking = {
          optimizeTcp = true;
        };

        virtualization = {
          enable = false;
          docker.enable = false;
          qemu.enable = false;
          podman.enable = false;
          distrobox.enable = false;
        };
      };
      usrEnv = {
        isWayland = true;
        desktop = "Hyprland";
        useHomeManager = true;
      };

      programs = {
        git.signingKey = "7F2F6BD6997FCDF7";

        cli = {
          enable = true;
          modernShell.enable = true;
        };
        tui.enable = true;
        gui.enable = true;

        zathura.enable = true;

        defaults = {
          bar = "ags";
        };
      };

      services = {
        smb = {
          enable = false;
          recive = {
            media = false;
            general = false;
          };
        };
        vscode-server.enable = true;
      };
    };

    hardware = {
      nvidia = mkIf (builtins.elem device.gpu ["nvidia" "hybrid-nv"]) {
        open = mkForce false;

        prime = {
          offload.enable = true;
          # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
          intelBusId = "PCI:0:2:0";

          # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
          nvidiaBusId = "PCI:1:0:0";
        };
      };
    };

    boot = {
      kernelParams =
        [
          "nohibernate"
        ]
        ++ optionals ((device.cpu == "intel") && (device.gpu != "hybrid-nv")) [
          "i915.enable_fbc=1"
          "i915.enable_psr=2"
        ];
    };

    console.earlySetup = true;
  };
}
