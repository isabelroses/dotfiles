{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib.modules) mkIf;
  inherit (lib.hardware) ldTernary;
  inherit (lib.validators) ifTheyExist isModernShell;
in
{
  config = mkIf (elem "isabel" config.garden.system.users) {
    users.users.isabel =
      {
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQDiHbMSinj8twL9cTgPOfI6OMexrTZyHX27T8gnMj2"
        ];

        home = "/${ldTernary pkgs "home" "Users"}/isabel";
        shell = if (isModernShell config) then pkgs.fish else pkgs.bashInteractive;
      }
      // (ldTernary pkgs {
        isNormalUser = true;
        uid = 1000;
        initialPassword = "changeme";

        # only add groups that exist
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
            "pipewire" # this give us access to the rt limits
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
      } { });
  };
}
