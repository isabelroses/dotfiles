{
  imports = [ ./users.nix ];

  garden = {
    device.profiles = [
      "laptop"
      "graphical"
    ];
  };
}
