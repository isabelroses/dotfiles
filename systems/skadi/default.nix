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
      cpu = "amd";
      gpu = null;
    };

    system = {
      boot = {
        loader = "systemd-boot";
      };
    };

    services = { };
  };
}
