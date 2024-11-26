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
  config = mkIf (elem "comfy" config.garden.system.users) {
    users.users.comfy =
      {
        openssh.authorizedKeys.keys = [ ];

        home = "/${ldTernary pkgs "home" "Users"}/comfy";
        shell = if (isModernShell config) then pkgs.fish else pkgs.bashInteractive;
      }
      // (ldTernary pkgs {
        isNormalUser = true;
        uid = 1001;
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
