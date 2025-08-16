{
  lib,
  pkgs,
  self,
  config,
  inputs,
  inputs',
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption mkSystemSecret;
in
{
  options.garden.services.blahaj = mkServiceOption "blahaj" { };

  config = mkIf config.garden.services.blahaj.enable {
    sops.secrets.blahaj-env = mkSystemSecret {
      file = "blahaj";
      key = "env";
    };

    # this is suchhhh a bad idea
    nix.settings.trusted-users = [ "blahaj" ];

    systemd.services.blahaj = {
      path = [ config.nix.package ];

      environment = {
        "NIX_PATH" = "nixpkgs=flake:${inputs.nixpkgs.outPath}";
      };
    };

    services = {
      blahaj = {
        enable = true;
        environmentFile = config.sops.secrets.blahaj-env.path;
      };

      nginx.virtualHosts."blahaj.isabelroses.com" = {
        locations."/".proxyPass = "http://127.0.0.1:3000";
      };
    };
  };
}
