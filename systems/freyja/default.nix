{
  # where to advertise the thread mesh, only used once the radio is set
  services.openthread-border-router.backboneInterfaces = [ "enp6s0" ];

  # reach the lan by its own addresses when away
  garden.system.networking.tailscale.advertiseRoutes = [ "192.168.10.0/24" ];
}
