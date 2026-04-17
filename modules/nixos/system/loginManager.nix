{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) getExe concatStringsSep;

  sessionData = config.services.displayManager.sessionData.desktops;
in
{
  services.greetd = {
    inherit (config.garden.profiles.graphical) enable;
    restart = true;
    useTextGreeter = true;

    settings = {
      default_session = {
        user = "greeter";
        command = concatStringsSep " " [
          (getExe pkgs.tuigreet)
          "--time"
          "--remember"
          "--remember-user-session"
          "--asterisks"
          "--sessions '${
            concatStringsSep ":" [
              "${sessionData}/share/xsessions"
              "${sessionData}/share/wayland-sessions"
            ]
          }'"
        ];
      };
    };
  };
}
