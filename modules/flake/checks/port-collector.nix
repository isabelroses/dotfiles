# collect every port a garden service declares on every nixos host, even if
# the service is disabled there, so a port can be moved between hosts freely.
# a service's port is its `port` option plus any option ending in `Port`

{
  lib,
  runCommandLocal,
  self,
}:
let
  inherit (lib.attrsets)
    attrNames
    attrValues
    filterAttrs
    mapAttrsToList
    ;
  inherit (lib.lists)
    concatLists
    concatMap
    filter
    groupBy
    length
    ;
  inherit (lib.strings) concatMapStringsSep concatStringsSep hasSuffix;

  isPort = name: value: (name == "port" || hasSuffix "Port" name) && builtins.isInt value;

  # [ { port = "3000"; owner = "pds.port"; } ... ]
  portsOf =
    services:
    concatMap (
      service:
      mapAttrsToList (option: port: {
        port = toString port;
        owner = "${service}.${option}";
      }) (filterAttrs isPort services.${service})
    ) (attrNames services);

  collisionsOn =
    host: nixos:
    map (owners: "${host}: ${concatStringsSep " and " owners}") (
      filter (owners: length owners > 1) (
        attrValues (
          builtins.mapAttrs (_: map (p: p.owner)) (groupBy (p: p.port) (portsOf nixos.config.garden.services))
        )
      )
    );

  # the installer doesn't import the garden modules
  hosts = filterAttrs (_: nixos: nixos.config ? garden) self.nixosConfigurations;

  collisions = concatLists (mapAttrsToList collisionsOn hosts);
in
runCommandLocal "port-collector"
  {
    __structuredAttrs = true;
  }
  ''
    if [ ${toString (collisions != [ ])} ]; then
      echo "Port collisions detected between ${concatMapStringsSep ", " (s: s) collisions}"
      exit 1
    fi

    touch $out
  ''
