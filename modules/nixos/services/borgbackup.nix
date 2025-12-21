{
  lib,
  self,
  config,
  ...
}:
let
  inherit (self.lib) mkServiceOption mkSecret;

  cfg = config.garden.services.borgbackup;
in
{
  options.garden.services.borgbackup = mkServiceOption "borgbackup" { };

  config = lib.mkIf cfg.enable {
    sops.secrets.borg-sshkey = mkSecret {
      file = "borg";
      key = "sshkey";
    };
  };
}
