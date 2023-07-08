{
  config,
  lib,
  ...
}:
with lib; let
  device = config.modules.device;
  cfg = config.modules.services;
  acceptedTypes = ["server" "hybrid"];
in
  mkIf (builtins.elem device.type acceptedTypes && cfg.jellyfin.enable) {
    services = {
      jellyfin = {
        enable = true;
        group = "jellyfin";
        user = "jellyfin";
        openFirewall = true;
      };
    };
  }
