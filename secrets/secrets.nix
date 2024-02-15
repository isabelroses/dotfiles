let
  users.isabel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQDiHbMSinj8twL9cTgPOfI6OMexrTZyHX27T8gnMj2 isabel@isabelroses.com";

  # hosts = {
  #   hydra = "";
  # };

  default = [users.isabel];
in {
  "git-credentials.age".publicKeys = default;
  "wakatime.age".publicKeys = default;

  # git ssh keys
  "gh-key.age".publicKeys = default;
  "gh-key-pub.age".publicKeys = default;
  "aur-key.age".publicKeys = default;
  "aur-key-pub.age".publicKeys = default;

  # ORACLE vps'
  "openvpn-key.age".publicKeys = default;
  "amity-key.age".publicKeys = default;

  # All nixos machines
  "nixos-key.age".publicKeys = default;
  "nixos-key-pub.age".publicKeys = default;

  # server
  "cloudflared-hydra.age".publicKeys = default;
  "cloudflare-cert-api.age".publicKeys = default;

  # mailserver
  "mailserver-isabel.age".publicKeys = default;
  "mailserver-vaultwarden.age".publicKeys = default;
  "mailserver-database.age".publicKeys = default;
  "mailserver-grafana.age".publicKeys = default;
  "mailserver-git.age".publicKeys = default;
  "mailserver-noreply.age".publicKeys = default;
  "mailserver-spam.age".publicKeys = default;

  "mailserver-grafana-nohash.age".publicKeys = default;
  "mailserver-git-nohash.age".publicKeys = default;

  "vikunja-env.age".publicKeys = default;

  "nextcloud-passwd.age".publicKeys = default;

  "vaultwarden-env.age".publicKeys = default;

  "matrix.age".publicKeys = default;

  # plausable
  "plausible-key.age".publicKeys = default;
  "plausible-admin.age".publicKeys = default;

  #wakapi
  "wakapi.age".publicKeys = default;
  "wakapi-mailer.age".publicKeys = default;

  "mongodb-passwd.age".publicKeys = default;
}
