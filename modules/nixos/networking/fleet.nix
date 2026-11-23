# the fleet is systems/fleet.toml: facts about every host and the garden.services
# each one runs. every host reads all of it, so no host has to evaluate another
{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (lib.types) attrsOf submodule;

  # not every host has an entry
  fleet = config.garden.fleet.${config.networking.hostName} or { };
  wakeOnLan = fleet.wakeOnLan or null;
in
{
  options.garden.fleet = mkOption {
    type = attrsOf (submodule "${self}/systems/fleet.nix");
    default = { };
    description = "Every host in systems/fleet.toml, identical on all of them, so no host has to evaluate another to learn about it";
  };

  config = {
    garden.fleet = lib.trivial.importTOML "${self}/systems/fleet.toml";

    networking = mkIf (wakeOnLan != null) {
      interfaces.${wakeOnLan}.wakeOnLan.enable = true;
      firewall.allowedUDPPorts = [ 9 ];
    };
  };
}
