{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isWayland isAcceptedDevice;
  inherit (lib.services) mkGraphicalService;

  acceptedTypes = [
    "desktop"
    "laptop"
    "lite"
    "hybrid"
  ];
in
{
  config = mkIf ((isAcceptedDevice osConfig acceptedTypes) && (isWayland osConfig)) {
    systemd.user.services = {
      cliphist = mkGraphicalService {
        Unit.Description = "Clipboard history service";
        Service = {
          ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${getExe pkgs.cliphist} store";
          Restart = "always";
        };
      };
    };
  };
}
