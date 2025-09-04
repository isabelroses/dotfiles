# collect all the ports even if they are disabled, we want to avoid any conflicts
{
  lib,
  config,
  ...
}:
let
  srvs = lib.mapAttrs (_: srv: srv.port) config.garden.services;

  # from port = 3000; to servicesOnPort.3000 = [ "pds" "kittr" ];
  portsToServices = lib.foldl' (
    acc: srv:
    let
      port = toString srvs.${srv};
    in
    acc
    // {
      ${port} = if (acc ? ${port}) then acc.${port} ++ [ srv ] else [ srv ];
    }
  ) { } (lib.attrNames srvs);

  # i use "0" as a catch all for services that don't use a port
  portsToServicesClean = portsToServices // {
    "0" = [ ];
  };

  collissions = lib.filter (srvList: lib.length srvList > 1) (lib.attrValues portsToServicesClean);
in
{
  assertions = [
    {
      assertion = collissions == [ ];
      message = "Port collisions detected between services: ${
        lib.concatMapStringsSep ", " (s: lib.concatStringsSep " and " s) collissions
      }";
    }
  ];
}
