{
  lib,
  _class,
  config,
  ...
}:
let
  inherit (lib.attrsets) genAttrs;
  inherit (lib.modules) mkDefault;
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
          uid = mkDefault 1000;
          isNormalUser = true;

          extraGroups = [
            "wheel"
            "nix"
            "network"
            "networkmanager"
            "systemd-journal"
            "audio"
            "pipewire" # this give us access to the rt limits
            "video"
            "input"
            "plugdev"
            "lp"
            "tss" # tpm2
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
