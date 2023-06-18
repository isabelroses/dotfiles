{
  pkgs,
  config,
  lib,
  ...
}: {
  users.groups.cloudflared = {};
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
    uid = 1001;
    shell = pkgs.fish;
    initialPassword = "changeme";
    #openssh.authorizedKeys.keys = keys;
  };
}
