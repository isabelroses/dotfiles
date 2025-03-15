let
  users = {
    isabel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQDiHbMSinj8twL9cTgPOfI6OMexrTZyHX27T8gnMj2";
    robin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKKxTuK2A7wbXnjkIhDrze4B5Uj2rnpmPAWGjPDMPiyk";
  };

  hosts = {
    amaterasu = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILNvBuKUksco5TldoEMthQcvr6TOh9Aun93kYUAq22gE";
      owner = "isabel";
    };
    # bmo = {
    #   key = "";
    #   owner = "robin";
    # };
    # cottage = {
    #   key = "";
    #   owner = "robin";
    # };
    hestia = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFNJv2ng+BJV2YDWAmaWFu7arLrsT2jpshUPTvdHBlxN";
      owner = "isabel";
    };
    hydra = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKMJroewVs8Iyf+/Ofk6q36D1OzVW0b04yyS3IVwNmCb";
      owner = "isabel";
    };
    minerva = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFluIN96lPhNvf2JsA2E+HjuQbDseD2sQJOgQbspJWW0";
      owner = "isabel";
    };
    tatsumaki = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFK5AFIUzlIoFmyz5/Ni1F3Xj1tppj/pMXD9GfMP4DV";
      owner = "isabel";
    };
    valkyrie = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAn1inws4uXxbv72IHphlLAVlmsaln2szDRsdlM0g7Hu";
      owner = "isabel";
    };
    wisp = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7cduddxQbnFeBWjt9L6Uml5mjnfEOxZqd4LoyRDTmg";
      owner = "robin";
    };
  };

  types = with hosts; {
    servers = [
      hestia
      minerva
    ];
    workstations = [
      amaterasu
      # bmo
      # cottage
      tatsumaki
      valkyrie
      wisp
    ];
    hybrid = [ hydra ];
  };

  defAccess =
    list: urs:
    let
      listcombined = list ++ types.hybrid;
      filtered = builtins.filter (host: builtins.any (x: host.owner == x) urs) listcombined;
      keys = builtins.map (host: host.key) filtered;
    in
    {
      publicKeys = keys ++ map (user: users.${user}) urs;
    };

  defAccessIsabel = list: defAccess list [ "isabel" ];
  defAccessRobin = list: defAccess list [ "robin" ];
  defAccessAll = list: defAccess list (builtins.attrNames users);
in
{
  # isabel's secrets
  "wakatime.age" = defAccessIsabel (types.workstations ++ types.servers);

  # git ssh keys
  "keys/gh.age" = defAccessIsabel (types.workstations ++ types.servers);
  "keys/gh-pub.age" = defAccessIsabel (types.workstations ++ types.servers);
  "keys/aur.age" = defAccessIsabel (types.workstations ++ types.servers);
  "keys/aur-pub.age" = defAccessIsabel (types.workstations ++ types.servers);
  "keys/gpg.age" = defAccessIsabel types.workstations;

  "uni/gitconf.age" = defAccessIsabel types.workstations;
  "uni/ssh.age" = defAccessIsabel types.workstations;
  "uni/central.age" = defAccessIsabel types.workstations;

  # All nixos machines
  "keys/nixos.age" = defAccessIsabel (types.workstations ++ types.servers);
  "keys/nixos-pub.age" = defAccessIsabel (types.workstations ++ types.servers);

  # ORACLE vps'
  "keys/openvpn.age" = defAccessIsabel types.workstations;
  "keys/amity.age" = defAccessIsabel types.workstations;

  # server
  "cloudflare/hydra.age" = defAccessIsabel types.servers;
  "cloudflare/cert-api.age" = defAccessIsabel types.servers;

  # buildbot
  "buildbot/worker.age" = defAccessIsabel types.servers;
  "buildbot/workers.age" = defAccessIsabel types.servers;
  "buildbot/gh-private-key.age" = defAccessIsabel types.servers;
  "buildbot/gh-webhook-secret.age" = defAccessIsabel types.servers;
  "buildbot/gh-oauth.age" = defAccessIsabel types.servers;

  # attic
  "attic/env.age" = defAccessIsabel types.servers;
  "attic/prod-auth-token.age" = defAccessIsabel types.servers;
  "attic/netrc.age" = defAccessIsabel types.servers;

  # mailserver
  "mailserver/isabel.age" = defAccessIsabel types.servers;
  "mailserver/robin.age" = defAccessAll types.servers;
  "mailserver/vaultwarden.age" = defAccessIsabel types.servers;
  "mailserver/database.age" = defAccessIsabel types.servers;
  "mailserver/grafana.age" = defAccessIsabel types.servers;
  "mailserver/git.age" = defAccessIsabel types.servers;
  "mailserver/noreply.age" = defAccessIsabel types.servers;
  "mailserver/spam.age" = defAccessIsabel types.servers;

  "mailserver/grafana-nohash.age" = defAccessIsabel types.servers;
  "mailserver/git-nohash.age" = defAccessIsabel types.servers;

  # kanidm
  "kanidm/admin-password.age" = defAccessIsabel types.servers;
  "kanidm/idm-admin-password.age" = defAccessIsabel types.servers;
  "kanidm/oauth2/grafana.age" = defAccessIsabel types.servers;
  "kanidm/oauth2/forgejo.age" = defAccessIsabel types.servers;

  "grafana-oauth2.age" = defAccessIsabel types.servers;

  "blahaj-env.age" = defAccessIsabel types.servers;

  "nixpkgs-fedibot-env.age" = defAccessIsabel types.servers;

  "vikunja-env.age" = defAccessIsabel types.servers;

  "nextcloud-passwd.age" = defAccessIsabel types.servers;

  "vaultwarden-env.age" = defAccessIsabel types.servers;

  "matrix/env.age" = defAccessIsabel types.servers;

  # plausible
  "plausible/key.age" = defAccessIsabel types.servers;
  "plausible/admin.age" = defAccessIsabel types.servers;

  # wakapi
  "wakapi.age" = defAccessIsabel types.servers;
  "wakapi-mailer.age" = defAccessIsabel types.servers;

  "mongodb-passwd.age" = defAccessIsabel types.servers;

  # robin's keys
  "keys/robin.age" = defAccessRobin (types.workstations ++ types.servers);
  "keys/robin-gpg.age" = defAccessRobin types.workstations;
  "keys/robin-gh.age" = defAccessRobin (types.workstations ++ types.servers);
  "keys/robin-gh-pub.age" = defAccessRobin (types.workstations ++ types.servers);
  "keys/robin-email.age" = defAccessRobin (types.workstations ++ types.servers);
}
