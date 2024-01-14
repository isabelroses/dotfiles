{
  pkgs,
  config,
  lib,
  ...
}: let
  keys = [
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQDiHbMSinj8twL9cTgPOfI6OMexrTZyHX27T8gnMj2 isabel@isabelroses.com''
  ];
in {
  boot.initrd.network.ssh.authorizedKeys = keys;

  users.users.isabel = {
    isNormalUser = true;
    extraGroups =
      [
        "wheel"
        "nix"
      ]
      ++ lib.ifTheyExist config [
        "network"
        "networkmanager"
        "systemd-journal"
        "audio"
        "video"
        "input"
        "plugdev"
        "lp"
        "tss"
        "power"
        "wireshark"
        "mysql"
        "docker"
        "podman"
        "git"
        "libvirtd"
        "cloudflared"
      ];
    uid = 1000;
    shell = pkgs.fish;
    hashedPasswordFile = config.sops.secrets.user-isabel-password.path;
    openssh.authorizedKeys.keys = keys;
  };
}
