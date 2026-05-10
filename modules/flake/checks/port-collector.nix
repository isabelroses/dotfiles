# collect all the ports even if they are disabled, we want to avoid any conflicts

{
  lib,
  runCommandLocal,
  self,
}:
let
  inherit (lib.attrsets) foldlAttrs;
  inherit (lib.lists) filter length;
  inherit (lib.strings) concatMapStringsSep concatStringsSep;

  # build {"3000" = ["pds" "kittr"]; "0" = [ ... ]; ...} in a single pass.
  portsToServices = foldlAttrs (
    acc: name: srv:
    let
      port = toString (srv.port or 0);
    in
    acc // { ${port} = (acc.${port} or [ ]) ++ [ name ]; }
  ) { } self.nixosConfigurations.amaterasu.config.garden.services;

  # "0" is the catch all for services that don't bind a port; we will drop it
  # before checking for collisions.
  collissions = filter (srvList: length srvList > 1) (
    builtins.attrValues (removeAttrs portsToServices [ "0" ])
  );
in
runCommandLocal "port-collector"
  {
    __structuredAttrs = true;
  }
  ''
    if [ ${toString (collissions != [ ])} ]; then
      echo "Port collisions detected between services ${
        concatMapStringsSep ", " (s: concatStringsSep " and " s) collissions
      }"
      exit 1
    fi

    touch $out
  ''
