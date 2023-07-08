{
  pkgs,
  config,
  lib,
  ...
}: let
  keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3AeKdY2eQmK78Ll3bms8yxmqe7BPWMph+QLZ2Fy33XGVDyxTSAK3LJWwfEmjEoQE/4UiFxnrzslrIsIuRYV//tV+aPfmyoBkAxbaWaJ3aujZYGpxD86MtnFwdfNRcl2fKJnTbPSAY0VM5p08A/eNe40WVwXAbXFHyJLbMn5Se1WGuZrWOtoD9reVjRNOh1EkpZVrbjv3rWpK4SDcJCdA9dGxxVXMsy7ErIOzit/g/4IQ+F8zEQRRbSToZYCU2+bFQP5Y1ujPMCxwtYfNEq0rrvgI73ejwhJAdjRHoKv2q8qN9HzYLm3nVipcj6mpV9T3ENHpKuyz1oB735lUh7vcJzu+cgix91RO3bKUtQ0yaUc1nogf8pceGTCbByHxy0qeNy9IgXfW1ZMJ7H1GttzUIsa4q1HLmj1MfbSvbdP4uU+gLflZgm1/9+N0IA4md4Ljpwgik9CsaVucaC/0vPnzASVTrvpMDNu/TlKLytdLKpbQ6Yk1YZPvUbVUZ3xfvJOE= isabel"
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
