{ lib, config, ... }:
let
  inherit (lib) mkIf mkForce;
  inherit (config.modules) device;
in
{
  imports = [ ./hardware.nix ];

  config = {
    modules = {
      device = {
        type = "desktop";
        cpu = "intel";
        gpu = "nvidia";
        hasTPM = true;
        monitors = [
          "HDMI-1"
          "DP-1"
        ];
        hasBluetooth = true;
        hasSound = true;
        keyboard = "us";
      };

      system = {
        mainUser = "isabel";

        boot = {
          loader = "systemd-boot";
          secureBoot = false;
          tmpOnTmpfs = true;
          enableKernelTweaks = true;
          loadRecommendedModules = true;

          plymouth = {
            enable = true;
            withThemes = true;
          };

          initrd = {
            enableTweaks = true;
            optimizeCompressor = true;
          };
        };

        fs = [
          "ext4"
          "vfat"
        ];
        video.enable = true;
        sound.enable = true;
        bluetooth.enable = false;
        printing.enable = false;
        yubikeySupport.enable = true;

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

          zathura.enable = true;
        };
      };
    };

    hardware.nvidia =
      mkIf
        (builtins.elem device.gpu [
          "nvidia"
          "hybrid-nv"
        ])
        {
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
}
