{lib, config, ...}: {
  imports = [./hardware-configuration.nix];
  config = {
    modules = {
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
          git.signingKey = "B4D9D513B1560D99";

          cli.enable = true;
          tui.enable = true;
          gui.enable = false;

          nur = {
            enable = true;
            bella = true;
            nekowinston = true;
          };
        };

        services = {
          vscode-server.enable = true;
          mailserver.enable = false;
          gitea.enable = false;
          isabelroses-web.enable = false;
        };
      };
    };

    zramSwap.enable = true;
    services.openssh.enable = true;
    users.users.root.openssh.authorizedKeys.keys = [
      ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZmzCZrKIdTSUf1GFWB9bF2nDRfjdWI4+jfcZbsscsSdNHBBaYnDjQftj8lVUMmSzjKasIeU3yKmuai6t2GBnIfxZq+5L/uvIZhYfgJwcjhLkXZL2CCG1UtxFV6Gwe2RJWA7VrGzhfU+Kjx6O7oCKlwy0M6cknUU+G17rqoGlOwDtMiDR+as6UoxeEf//xIdvBdEb3A+JGo4WVx1+/8XedKM5ngyY0zH6vKb12kudVMjJsqQ4cES8JozuL4LMEExsPRALPVGYQ69ulMLl4zkbbP2Ne5UO9Uf/BsBF2DJU3uWVIG6nAUIeNr4NXaa7h4/cnlpP+f4H/7MvOeif85TYU2WK+yiy11z7N6wxbB1/Mtq2sMldMq3Csb7A0GkeF1qXazG0yp4Oa0sene0JfPI3AsYSFOHuByVRkb6kI3f+d/xogwoLJ645olZLcobsqWoS4TQZHj44CTRseXzCQiUGBKV9Bb/7hqY7TbcwRd7cEW91lbXIzO6PUDhi1E59VqYE=''
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

      loader.grub = {
        enable = true;
        useOSProber = lib.mkForce false;
        efiSupport = lib.mkForce false;
        enableCryptodisk = false;
        theme = null;
        backgroundColor = null;
        splashImage = null;
        device = lib.mkForce "/dev/sda";
      };
    };
  };
}
