{
  pkgs,
  config,
  lib,
  ...
}: {
  boot.initrd.network.ssh.authorizedKeys = keys;

  users.users.isabel = {
    isNormalUser = true;
    extraGroups =
      [
        "wheel"
        "systemd-journal"
        "audio"
        "video"
        "input"
        "plugdev"
        "lp"
        "tss"
        "power"
        "nix"
      ]
      ++ lib.ifTheyExist config [
        "network"
        "networkmanager"
        "wireshark"
        "mysql"
        "docker"
        "podman"
        "git"
        "libvirtd"
      ];
    uid = 1001;
    shell = pkgs.fish;
    initialPassword = "changeme";
    #openssh.authorizedKeys.keys = keys;
  };
}
