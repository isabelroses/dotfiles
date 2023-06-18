{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  sys = config.modules.system.video;
  env = config.modules.usrEnv;
in {
  config = mkIf (sys.enable && env.isWayland) {
    environment.etc."greetd/environments".text = ''
      ${lib.optionalString (env.desktop == "Hyprland") "Hyprland"}
      zsh
    '';

    environment = {
      # Experimental wayland-native wine
      # https://nixos.wiki/wiki/Wine
      systemPackages = with pkgs; [wineWowPackages.waylandFull];
      variables = {
        NIXOS_OZONE_WL = "1";
        _JAVA_AWT_WM_NONEREPARENTING = "1";
        GDK_BACKEND = "wayland,x11";
        ANKI_WAYLAND = "1";
        MOZ_ENABLE_WAYLAND = "1";
        XDG_SESSION_TYPE = "wayland";
        SDL_VIDEODRIVER = "wayland";
        CLUTTER_BACKEND = "wayland";
        #WLR_DRM_NO_ATOMIC = "1";
        #WLR_BACKEND = "vulkan";
        #__GL_GSYNC_ALLOWED = "0";
        #__GL_VRR_ALLOWED = "0";
      };
    };
  };
}
