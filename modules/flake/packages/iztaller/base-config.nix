{
  garden = {
    device = {
      type = "laptop";
      cpu = "intel";
      gpu = null;
      monitors = [ "eDP-1" ];
      capabilities = {
        tpm = true;
        bluetooth = true;
        yubikey = true;
      };
    };

    system = {
      boot = {
        loader = "systemd-boot";
        secureBoot = false;
        loadRecommendedModules = true;
        enableKernelTweaks = true;
        initrd.enableTweaks = true;
      };

      bluetooth.enable = false;
      printing.enable = false;

      security = {
        fixWebcam = false;
        auditd.enable = true;
      };

      networking = {
        optimizeTcp = true;
        wirelessBackend = "iwd";
      };
    };
  };

  home-manager.users.isabel = {
    programs = {
      cli = {
        enable = true;
        modernShell.enable = true;
      };
      tui.enable = true;
      gui.enable = true;
    };
  };
}
