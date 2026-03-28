{
  imports = [ ./users.nix ];

  garden = {
    profiles = {
      workstation.enable = true;
      headless.enable = true;
    };

    device = {
      cpu = null;
      gpu = null;
      capabilities = {
        tpm = true;
        bluetooth = false;
      };
      keyboard = "us";
    };

    system = {
      boot = {
        loader = "none";
        secureBoot = false;
      };

      emulation.enable = true;
      bluetooth.enable = false;
    };
  };
}
