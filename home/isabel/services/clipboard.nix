{
  lib,
  self,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) isWayland hasProfile;
  inherit (self.lib.services) mkGraphicalService;

  acceptedTypes = [
    "desktop"
    "laptop"
    "lite"
    "hybrid"
  ];
in
{
  config = mkIf (hasProfile osConfig acceptedTypes && isWayland osConfig) {
    systemd.user.services.cliphist = mkGraphicalService {
      Unit.Description = "Clipboard history service";
      Service = {
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${getExe pkgs.cliphist} store";
        Restart = "always";
      };
    };
  };
}
