_: let
  makeServiceNsPhysical = name: {
    systemd.services."${name}".serviceConfig.NetworkNamespacePath = "/var/run/netns/physical";
  };
  makeSocketNsPhysical = name: {
    systemd.sockets."${name}".socketConfig.NetworkNamespacePath = "/var/run/netns/physical";
  };
  unRestrictNamespaces = name: {
    systemd.sockets."${name}".socketConfig.RestrictNamespaces = "~net";
  };
in {
  inherit makeSocketNsPhysical makeServiceNsPhysical unRestrictNamespaces;
}
