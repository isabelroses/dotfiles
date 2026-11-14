# a relay serves a relayed host's services at the port and domain it sees in
# its own evaluation, so the relayed host must agree on both

{
  lib,
  runCommandLocal,
  self,
}:
let
  inherit (lib.attrsets) filterAttrs mapAttrsToList;
  inherit (lib.lists) concatLists concatMap;
  inherit (lib.strings) concatStringsSep;

  hosts = self.nixosConfigurations;
  # the fleet is identical on every host that has one
  inherit (hosts.minerva.config.garden) fleet;

  relayed = filterAttrs (_: f: f.relay != null) fleet;

  mismatches = concatLists (
    mapAttrsToList (
      host: f:
      concatMap (
        name:
        let
          here = hosts.${host}.config.garden.services.${name};
          there = hosts.${f.relay.via}.config.garden.services.${name};
          differs =
            field:
            lib.lists.optional (here.${field} != there.${field})
              "${name}.${field} is ${toString here.${field}} on ${host} but ${f.relay.via} relays ${toString there.${field}}";
        in
        differs "port" ++ differs "domain"
      ) f.relay.services
    ) relayed
  );
in
runCommandLocal "relay-contract"
  {
    __structuredAttrs = true;
  }
  ''
    if [ ${toString (mismatches != [ ])} ]; then
      echo "${concatStringsSep "\n" mismatches}"
      exit 1
    fi

    touch $out
  ''
