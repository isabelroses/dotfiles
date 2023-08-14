{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
in {
  imports = [
    ./systemd.nix
    inputs.vscode-server.nixosModules.default
  ];
  services = {
    cloudflared = mkIf (config.modules.services.cloudflare.enable) {
      enable = true;
      user = "${config.modules.system.mainUser}";
      tunnels."${config.modules.services.cloudflare.id}" = {
        credentialsFile = "${config.home-manager.users.${config.modules.system.mainUser}.sops.secrets.cloudflared-hydra.path}";
        default = "http_status:404";
        ingress = {
          "tv.isabelroses.com" = "http://localhost:8096";
        };
      };
    };
    vscode-server.enable = config.modules.services.vscode-server.enable;
    # monitor and control temparature
    thermald.enable = true;
    # handle ACPI events
    acpid.enable = true;
    # discard blocks that are not in use by the filesystem, good for SSDs
    fstrim.enable = true;
    # firmware updater for machine hardware
    fwupd.enable = true;
    # I don't use lvm, can be disabled
    lvm.enable = false;
    # enable smartd monitoering
    smartd.enable = true;
    # limit systemd journal size
    journald.extraConfig = ''
      SystemMaxUse=100M
      RuntimeMaxUse=50M
      SystemMaxFileSize=50M
    '';
  };
}
