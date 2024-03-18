let
  users.isabel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQDiHbMSinj8twL9cTgPOfI6OMexrTZyHX27T8gnMj2 isabel@isabelroses.com";

  hosts = {
    hydra = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKMJroewVs8Iyf+/Ofk6q36D1OzVW0b04yyS3IVwNmCb";
    luz = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGHXU5QFwqTAW/3MrHXfeqRlit4VrxhymLLb32RFSZjf";
    tatsumaki = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIU8hvjlgODQf80Is9qx2EjgcgK5jSqFcrRgQu5LTrAL";
    valkyrie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHnhUMQ+BtvcfPKJJbR8nFAQIB9KbrKRJlZSsheCL0j6";
  };

  types = with hosts; {
    servers = [luz];
    workstations = [tatsumaki valkyrie];
    hybrid = [hydra];
  };

  defAccess = list: list ++ [users.isabel] ++ types.hybrid;
in {
  "git-credentials.age".publicKeys = defAccess (types.workstations ++ types.servers);
  "wakatime.age".publicKeys = defAccess (types.workstations ++ types.servers);

  # git ssh keys
  "gh-key.age".publicKeys = defAccess (types.workstations ++ types.servers);
  "gh-key-pub.age".publicKeys = defAccess (types.workstations ++ types.servers);
  "aur-key.age".publicKeys = defAccess (types.workstations ++ types.servers);
  "aur-key-pub.age".publicKeys = defAccess (types.workstations ++ types.servers);

  # All nixos machines
  "nixos-key.age".publicKeys = defAccess (types.workstations ++ types.servers);
  "nixos-key-pub.age".publicKeys = defAccess (types.workstations ++ types.servers);

  # ORACLE vps'
  "openvpn-key.age".publicKeys = defAccess types.workstations;
  "amity-key.age".publicKeys = defAccess types.workstations;

  # server
  "cloudflared-hydra.age".publicKeys = defAccess types.servers;
  "cloudflare-cert-api.age".publicKeys = defAccess types.servers;

  # mailserver
  "mailserver-isabel.age".publicKeys = defAccess types.servers;
  "mailserver-vaultwarden.age".publicKeys = defAccess types.servers;
  "mailserver-database.age".publicKeys = defAccess types.servers;
  "mailserver-grafana.age".publicKeys = defAccess types.servers;
  "mailserver-git.age".publicKeys = defAccess types.servers;
  "mailserver-noreply.age".publicKeys = defAccess types.servers;
  "mailserver-spam.age".publicKeys = defAccess types.servers;

  "mailserver-grafana-nohash.age".publicKeys = defAccess types.servers;
  "mailserver-git-nohash.age".publicKeys = defAccess types.servers;

  "blahaj-env.age".publicKeys = defAccess types.servers;

  "vikunja-env.age".publicKeys = defAccess types.servers;

  "nextcloud-passwd.age".publicKeys = defAccess types.servers;

  "vaultwarden-env.age".publicKeys = defAccess types.servers;

  "matrix.age".publicKeys = defAccess types.servers;

  # plausable
  "plausible-key.age".publicKeys = defAccess types.servers;
  "plausible-admin.age".publicKeys = defAccess types.servers;

  #wakapi
  "wakapi.age".publicKeys = defAccess types.servers;
  "wakapi-mailer.age".publicKeys = defAccess types.servers;

  "mongodb-passwd.age".publicKeys = defAccess types.servers;
}
