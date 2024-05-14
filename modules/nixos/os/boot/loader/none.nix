{ lib, config, ... }:
let
  inherit (lib) mkIf mkForce;
  cfg = config.modules.system;
in
{
  config = mkIf (cfg.boot.loader == "none") {
    boot.loader = {
      grub.enable = mkForce false;
      systemd-boot.enable = mkForce false;
    };
  };
}
