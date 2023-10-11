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
        hostname = "hydra";

        boot = {
          loader = "systemd-boot";
          secureBoot = false;
          enableKernelTweaks = true;
          enableInitrdTweaks = true;
          loadRecommendedModules = true;
        };

        fs = ["ext4" "vfat"];
        video.enable = true;
        sound.enable = true;
        bluetooth.enable = true;
        printing.enable = false;

        security = {
          fixWebcam = false;
          auditd.enable = true;
        };

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

      programs = {
        git.signingKey = "CFF897835DD77813";

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

        nur = {
          enable = true;
          bella = true;
          nekowinston = true;
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
        cloudflared.enable = false;
        jellyfin = {
          enable = false;
          asDockerContainer = false;
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
