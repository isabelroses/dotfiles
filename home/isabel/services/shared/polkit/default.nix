{
  lib,
  osConfig,
  pkgs,
  ...
}:
with lib; let
  device = osConfig.modules.device;
  video = osConfig.modules.system.video;
  env = osConfig.modules.usrEnv;

  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  config = mkIf ((builtins.elem device.type acceptedTypes) && (video.enable && env.isWayland)) {
    # gnome polkit agent
    systemd.user.services.polkit-gnome-authentication-agent-1 = lib.mkGraphicalService {
      Service.ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    };
  };
}
