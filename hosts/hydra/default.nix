{config, ...}: {
  imports = [./hardware-configuration.nix];
  config = {
    modules = {
      device = {
        type = "hybrid";
        cpu = "intel";
        gpu = null;
        hasTPM = true;
        monitors = ["eDP-1"];
        hasBluetooth = true;
        hasSound = true;
      };
      system = {
        mainUser = "isabel";

        hostname = "hydra";

        boot = {
          loader = "systemd-boot";
          enableKernelTweaks = true;
          enableInitrdTweaks = true;
          loadRecommendedModules = true;
        };

        video.enable = true;
        sound.enable = true;
        bluetooth.enable = true;
        printing.enable = false;

        networking = {
          optimizeTcp = true;
        };

        virtualization = {
          enable = true;
          docker.enable = true;
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
          id = "32f941a8-e557-4d8a-bafd-52a7d65a5daf";
        };
        jellyfin = {
          enable = false;
          asDockerContainer = true;
        };
      };
      programs = {
        git.signingKey = "CFF897835DD77813";

        cli.enable = true;
        tui.enable = true;
        gui.enable = true;

        default = {
          bar = "ags";
        };

        nur = {
          enable = true;
          bella = true;
          nekowinston = true;
        };
      };
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
