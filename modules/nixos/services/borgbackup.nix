{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib) mkOption types mapAttrs;
  inherit (self.lib) mkServiceOption mkSecret mkPubs;

  cfg = config.garden.services.borgbackup;
in
{
  options.garden.services.borgbackup = mkServiceOption "borgbackup" { } // {
    jobs = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            paths = mkOption {
              type = types.listOf types.path;
              example = [
                "/home/user/Documents"
                "/etc"
              ];
              description = "List of paths to back up.";
            };

            exclude = mkOption {
              type = types.listOf types.str;
              example = [
                "*.cache"
                "*.tmp"
              ];
              description = "List of glob patterns to exclude from the backup.";
              default = [ ];
            };

            repo = mkOption {
              type = types.str;
              example = "repo";
              description = "The Borg repository location.";
            };

            passkeyFile = mkOption {
              type = types.path;
              example = "/run/secrets/borg-passkey";
              description = "Path to the file containing the Borg repository passkey.";
            };
          };
        }
      );
      default = { };
      description = "Define borg backup jobs.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.borg-sshkey = mkSecret {
      file = "borg";
      key = "sshkey";
    };

    services = {
      openssh.knownHosts = mkPubs "zh6120.rsync.net" [
        {
          type = "ssh-rsa";
          key = "AAAAB3NzaC1yc2EAAAADAQABAAABAQDPgHxQyaDaVxUefoUJZO/lITh0Gp0sqbP7HejQcCfZi7gAcuM6/IAuUXLHFImefCHh52x6T/cHxgL1qz26GKgdxykl06WRXlRIuE45QFSy/cd9JKr6l58fKq30ApmXRsCNwFrMlFPoEpCTqxzddZ9cLXs1Yt9dRxvFlQVEuAzw7ayvt8DE6RP9/CHYVp54wbbvUToECGwu70sxY1vFg51K+vNpvJ3J0t5j3s4c1Wls4BrIwqi2U8kqCq9Nj2CUIQqjM+93CSqEacR3qOGvG/6QMzd733wzpJ/iZee+lcyTYzA0YNMosnaF01hrv7NMwtZ6xRFLlJZtMZ7JpfySrOBr";
        }
        {
          type = "ecdsa-sha2-nistp256";
          key = "AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLR2uz+YLn2KiQK0Luu8rhfWS6LHgUfGAWB1j8rM2MKn4KZ2/LhIX1CYkPKMTPxHr6mzayeL1T1hyJIylxXv0BY=";
        }
        {
          type = "ssh-ed25519";
          key = "AAAAC3NzaC1lZDI1NTE5AAAAIJtclizeBy1Uo3D86HpgD3LONGVH0CJ0NT+YfZlldAJd";
        }
      ];

      borgbackup.jobs = mapAttrs (_name: jobCfg: {
        inherit (jobCfg) paths exclude;
        repo = "zh6120@zh6120.rsync.net:${jobCfg.repo}";
        environment.BORG_RSH = "ssh -i ${config.sops.secrets.borg-sshkey.path}";
        encryption = {
          mode = "repokey-blake2";
          passCommand = "cat ${jobCfg.passkeyFile}";
        };
        extraArgs = [ "--remote-path=borg14" ];
        extraCreateArgs = [
          "--progress"
          "--stats"
        ];
        compression = "auto,zstd";
        startAt = "Sat 02:30";
        prune.keep.last = 5;
        inhibitsSleep = true;
        persistentTimer = true;
        doInit = false;
      }) cfg.jobs;
    };
  };
}
