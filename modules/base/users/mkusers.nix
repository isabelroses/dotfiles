{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkDefault;
  inherit (lib.attrsets) attrValues;
  inherit (self.lib.hardware) ldTernary;
  inherit (self.lib.validators) ifTheyExist;
in
{
  users.users.isabel =
    {
      home = "/" + (ldTernary pkgs "home" "Users") + "/isabel";
      shell = config.garden.users.isabel.garden.packages.fish;
      packages = attrValues config.garden.users.isabel.garden.packages;
    }
    // (ldTernary pkgs {
      uid = mkDefault 1000;
      isNormalUser = true;
      initialPassword = mkDefault "changeme";

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
}
