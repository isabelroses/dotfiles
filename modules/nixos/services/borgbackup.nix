{
  lib,
  self,
  config,
  ...
}:
let
  inherit (self.lib) mkServiceOption mkSystemSecret;

  cfg = config.garden.services.borgbackup;
in
{
  options.garden.services.borgbackup = mkServiceOption "borgbackup" { };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      borg-sshconf = mkSystemSecret {
        file = "borg";
        key = "sshconf";
      };
      borg-sshkey = mkSystemSecret {
        file = "borg";
        key = "sshkey";
        path = "/root/.ssh/borg";
      };
    };

    programs.ssh.extraConfig = ''
      Include ${config.sops.secrets.borg-sshconf.path}
    '';
  };
}
