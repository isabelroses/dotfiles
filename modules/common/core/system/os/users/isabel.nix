{
  pkgs,
  config,
  lib,
  ...
}: let
  keys = [
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFEtTMRG9pfuOjlLmq/NybTZCIKL66tLNSM4CBILYda3 isabel''
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
    initialPassword = "changeme";
    openssh.authorizedKeys.keys = keys;
  };
}
