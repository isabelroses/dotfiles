{
  config,
  lib,
  ...
}:
with lib; let
  device = config.modules.device;
in {
  imports = [./hardware-configuration.nix];
  config = {
    modules = {
      device = {
        type = "hybrid";
        cpu = "intel";
        gpu = null;
        #hasTPM = true;
        monitors = ["eDP-1"];
        hasBluetooth = true;
        hasSound = true;
      };
      system = {
        username = "isabel";

        hostname = "hydra";

        boot = {
          loader = "systemd-boot";
          enableKernelTweaks = true;
          enableInitrdTweaks = true;
          loadRecommendedModules = true;
        };

        video.enable = true;
        sound.enable = true;
        bluetooth.enable = false;
        printing.enable = false;

        networking = {
          optimizeTcp = true;
        };

        virtualization = {
          enable = true;
          docker.enable = true;
          qemu.enable = false;
          podman.enable = false;
          distrobox.enable = true;
        };
      };
      usrEnv = {
        isWayland = true;
        desktop = "Hyprland";
        useHomeManager = true;
      };
      services = {
        smb = {
          enable = true;
          recive = {
            media = true;
            general = true;
          };
        };
        vscode-server.enable = true;
        cloudflare = {
          enable = true;
        };
      };
      programs = {
        git.signingKey = "CFF897835DD77813";

        cli.enable = true;
        gui.enable = true;

        nur = {
          enable = true;
          bella = true;
          nekowinston = true;
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
