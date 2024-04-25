{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) ldTernary ifTheyExist;

  keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQDiHbMSinj8twL9cTgPOfI6OMexrTZyHX27T8gnMj2 isabel@isabelroses.com"];
in {
  # boot.initrd.network.ssh.authorizedKeys = mkIf isLinux keys;

  users.users.isabel =
    {
      openssh.authorizedKeys.keys = keys;
      home = "/${ldTernary pkgs "home" "Users"}/isabel";
      shell = ldTernary pkgs pkgs.fish pkgs.zsh;
    }
    // (
      ldTernary pkgs {
        isNormalUser = true;
        uid = 1000;
        initialPassword = "changeme";
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
