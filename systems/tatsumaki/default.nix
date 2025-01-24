{
  imports = [ ./usrs.nix ];

  garden = {
    device.type = "laptop";

    environment = {
      desktop = null;
      useHomeManager = true;
    };
  };
}
