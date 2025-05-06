{
  imports = [ ./users.nix ];

  garden = {
    profiles = {
      laptop.enable = true;
      graphical.enable = true;
      workstation.enable = true;
    };
  };
}
