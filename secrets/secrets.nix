let
  users.isabel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQDiHbMSinj8twL9cTgPOfI6OMexrTZyHX27T8gnMj2 isabel@isabelroses.com";

  hosts = {
    hydra = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKMJroewVs8Iyf+/Ofk6q36D1OzVW0b04yyS3IVwNmCb";
    amaterasu = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILNvBuKUksco5TldoEMthQcvr6TOh9Aun93kYUAq22gE";
    minerva = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFluIN96lPhNvf2JsA2E+HjuQbDseD2sQJOgQbspJWW0";
    tatsumaki = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFK5AFIUzlIoFmyz5/Ni1F3Xj1tppj/pMXD9GfMP4DV";
    valkyrie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHnhUMQ+BtvcfPKJJbR8nFAQIB9KbrKRJlZSsheCL0j6";
  };

  types = with hosts; {
    servers = [ minerva ];
    workstations = [
      amaterasu
      tatsumaki
      valkyrie
    ];
    hybrid = [ hydra ];
  };

  defAccess = list: { publicKeys = list ++ [ users.isabel ] ++ types.hybrid; };
in
{
  "wakatime.age" = defAccess (types.workstations ++ types.servers);

  # git ssh keys
  "keys/gh.age" = defAccess (types.workstations ++ types.servers);
  "keys/gh-pub.age" = defAccess (types.workstations ++ types.servers);
  "keys/aur.age" = defAccess (types.workstations ++ types.servers);
  "keys/aur-pub.age" = defAccess (types.workstations ++ types.servers);
  "keys/gpg.age" = defAccess types.workstations;

  "uni/gitconf.age" = defAccess types.workstations;
  "uni/ssh.age" = defAccess types.workstations;
  "uni/central.age" = defAccess types.workstations;

  # All nixos machines
  "keys/nixos.age" = defAccess (types.workstations ++ types.servers);
  "keys/nixos-pub.age" = defAccess (types.workstations ++ types.servers);

  # ORACLE vps'
  "keys/openvpn.age" = defAccess types.workstations;
  "keys/amity.age" = defAccess types.workstations;

  # server
  "cloudflare/hydra.age" = defAccess types.servers;
  "cloudflare/cert-api.age" = defAccess types.servers;

  # mailserver
  "mailserver/isabel.age" = defAccess types.servers;
  "mailserver/vaultwarden.age" = defAccess types.servers;
  "mailserver/database.age" = defAccess types.servers;
  "mailserver/grafana.age" = defAccess types.servers;
  "mailserver/git.age" = defAccess types.servers;
  "mailserver/noreply.age" = defAccess types.servers;
  "mailserver/spam.age" = defAccess types.servers;

  "mailserver/grafana-nohash.age" = defAccess types.servers;
  "mailserver/git-nohash.age" = defAccess types.servers;

  # kanidm
  "kanidm/admin-password.age" = defAccess types.servers;
  "kanidm/idm-admin-password.age" = defAccess types.servers;
  "kanidm/oauth2/grafana.age" = defAccess types.servers;
  "kanidm/oauth2/forgejo.age" = defAccess types.servers;

  "grafana-oauth2.age" = defAccess types.servers;

  "blahaj-env.age" = defAccess types.servers;

  "vikunja-env.age" = defAccess types.servers;

  "nextcloud-passwd.age" = defAccess types.servers;

  "vaultwarden-env.age" = defAccess types.servers;

  "matrix/env.age" = defAccess types.servers;
  "matrix/sync.age" = defAccess types.servers;

  # plausible
  "plausible/key.age" = defAccess types.servers;
  "plausible/admin.age" = defAccess types.servers;

  #wakapi
  "wakapi.age" = defAccess types.servers;
  "wakapi-mailer.age" = defAccess types.servers;

  "mongodb-passwd.age" = defAccess types.servers;
}
