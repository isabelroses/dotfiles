{
  lib,
  self,
  _class,
  config,
  ...
}:
let
  inherit (lib.attrsets) genAttrs;
  inherit (lib.modules) mkDefault;
  inherit (self.lib) ifTheyExist;
in
{
  users.users = genAttrs config.garden.system.users (
    name:
    let
      inherit (config.home-manager.users.${name}.garden.programs.defaults) shell;
    in
    {
      shell = "/run/current-system/sw/bin/${shell}";
    }
    // (
      if _class == "nixos" then
        {
          home = "/home/${name}";

          uid = mkDefault 1000;
          isNormalUser = true;

          # only add groups that exist
          extraGroups = [
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
        }
      else
        { home = "/Users/${name}"; }
    )
  );
}
