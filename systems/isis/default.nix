{
  imports = [ ./hardware.nix ];

  garden = {
    profiles = {
      headless.enable = true;
      server.enable = true;
      upcloud.enable = true;
    };

    services = {
      nginx = {
        enable = true;
        domain = "tgirl.cloud";
      };

      uptime-kuma.enable = true;
    };
  };
}
