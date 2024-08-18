{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (config.garden) device;
in
{
  # limit systemd journal size
  # https://wiki.archlinux.org/title/Systemd/Journal#Persistent_journals
  services.journald.extraConfig = mkIf (device.type != "server") ''
    SystemMaxUse=100M
    RuntimeMaxUse=50M
    SystemMaxFileSize=50M
  '';
}
