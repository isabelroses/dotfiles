{
  lib,
  pkgs,
  osConfig,
  ...
}: let
  inherit (lib) mkIf isAcceptedDevice isWayland mkGraphicalService getExe;
  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
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
