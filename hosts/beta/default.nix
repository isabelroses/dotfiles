{config, ...}: {
  imports = [./hardware-configuration.nix];
  config = {
    modules = {
      device = {
        type = "server";
        cpu = "intel";
        gpu = null;
        hasTPM = false;
        hasBluetooth = false;
        hasSound = false;
      };
      system = {
        mainUser = "isabel";
        hostname = "beta";

        boot = {
          loader = "systemd-boot";
          enableKernelTweaks = true;
          enableInitrdTweaks = true;
          loadRecommendedModules = true;
        };

        video.enable = false;
        sound.enable = false;
        bluetooth.enable = false;
        printing.enable = false;

        networking = {
          optimizeTcp = false;
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
        isWayland = false;
        useHomeManager = true;

        programs = {
          git.signingKey = "";

          cli.enable = true;
          gui.enable = false;

          nur = {
            enable = true;
            bella = true;
            nekowinston = true;
          };
        };

        services = {
          smb = {
            enable = true;
          };
          vscode-server.enable = true;
          mailserver.enable = true;
        };
      };
    };

    services.openssh.enable = true;
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDQhSDXRDS5ABDyCPOZ2B3bl455Mlzb32vmofdkXJCNXW98jUeCyaZk8XHRta06KeADFMvpwDEzjGz6Zb+NJIfMkh20mVdOpTHrA80cER1F2SlNf9fmZIgOyCzSUOSGqXHsWppikHmKzv1hPifQYoqWdRXN7bD9Jk5JjgxGcaXkICcV93s/tRy5Yl5l5LhM00fUDXUF85xnmqU3Ujepx0gknE0qaqgT+kFRe0hy7HIkjrEjMqy5nfHFlJG/XAxrHKK9p/BvvCgO/xiRimK2UgfH/5jml20EytVeZ6fIAeyVLvWA/FtLyaafoLqmETV6BhUnk8PtdAxjGQTQXZmUOv2D0Lvmxo1GqjYVPOfhINBprUaRwxIFM57SpwmXmGVWOlyTgTtBoPewUQ/QwT5cVV+a8ASeEhrFB4TzHxK4RM8++zL0eVtESW+L+/rsmfUHIIEXnLvVmnb8t0AWpWxQWaEe7YaNS9VNtm6gK0wl12PZXqN5K4eCXIyrsCbUdaldnts= root"
    ];

    boot = {
      growPartition = !config.boot.initrd.systemd.enable;
      kernelParams = ["net.ifnames=0"];
      kernel = {
        sysctl = {
          "net.ipv4.ip_forward" = true;
          "net.ipv6.conf.all.forwarding" = true;
        };
      };
    };
  };
}
