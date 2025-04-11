{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.services) mkServiceOption;

  cfg = config.garden.services.anubis;
in
{
  options.garden.services.anubis = mkServiceOption "anubis" { };

  config = mkIf cfg.enable {
    # add anubis to the nginx group, such that it can use unix sockets and TCP or somethng like that
    # see <https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/anubis.md>
    users.users.nginx.extraGroups = [ config.users.groups.anubis.name ];
  };
}
