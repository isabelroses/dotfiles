{
  imports = [
    ./hardware.nix
    ./users.nix
  ];

  garden = {
    profiles = {
      headless.enable = true;

      server = {
        enable = true;

        hetzner = {
          enable = true;
          ipv4 = "116.203.57.153";
          ipv6 = "2a01:4f8:c2c:b73d::/64";
        };
      };
    };

    device = {
      cpu = "intel";
      gpu = null;
    };

    services = {
      nginx = {
        enable = true;
        domain = "tgirl.cloud";
      };
      attic.enable = true;
    };
  };
}
