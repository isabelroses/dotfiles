{
  lib,
  self,
  _class,
  config,
  ...
}:
let
  inherit (lib)
    mkDefault
    mergeAttrsList
    optionalAttrs
    genAttrs
    ;
  inherit (self.lib) ifTheyExist;
in
{
  users.users = genAttrs config.garden.system.users (
    name:
    mergeAttrsList [
      (optionalAttrs (_class == "darwin") {
        home = "/Users/${name}";
      })

      (optionalAttrs (_class == "nixos") {
        home = "/home/${name}";

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
      })
    ]
  );
}
