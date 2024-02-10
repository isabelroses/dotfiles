{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) ldTernary mkIf ifTheyExist;
  inherit (pkgs.stdenv) isLinux;

  keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQDiHbMSinj8twL9cTgPOfI6OMexrTZyHX27T8gnMj2 isabel@isabelroses.com"];
in {
  boot.initrd.network.ssh.authorizedKeys = mkIf isLinux keys;

  users.users.isabel =
    {
      hashedPasswordFile = config.sops.secrets.user-isabel-password.path;
      openssh.authorizedKeys.keys = keys;
      home = ldTernary pkgs "/home/isabel" "/Users/isabel";
      shell = ldTernary pkgs pkgs.fish pkgs.zsh;
    }
    // (
      ldTernary pkgs {
        isNormalUser = true;
        uid = 1000;
        extraGroups =
          [
            "wheel"
            "nix"
          ]
          ++ ifTheyExist config [
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
      } {}
    );
}
