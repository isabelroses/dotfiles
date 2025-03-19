{
  imports = [
    ./hardware.nix
    ./users.nix
  ];

  garden = {
    device = {
      profiles = [
        "headless"
        "server"
      ];
      cpu = "intel";
      gpu = null;
      hetzner = {
        enable = true;
        ipv4 = "116.203.57.153";
        ipv6 = "2a01:4f8:c2c:b73d::/64";
      };
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
