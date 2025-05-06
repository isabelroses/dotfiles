{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) getExe mkIf;
  inherit (self.lib) mkGraphicalService;
in
{
  config = mkIf config.garden.profiles.graphical.enable {
    systemd.user.services.cliphist = mkGraphicalService {
      Unit.Description = "Clipboard history service";
      Service = {
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${getExe pkgs.cliphist} store";
        Restart = "always";
      };
    };
  };
}
