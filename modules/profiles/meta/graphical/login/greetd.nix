{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (config.modules) system environment;
  inherit (lib) mkIf getExe concatStringsSep;

  sessionData = config.services.displayManager.sessionData.desktops;
  sessionPath = concatStringsSep ":" [
    "${sessionData}/share/xsessions"
    "${sessionData}/share/wayland-sessions"
  ];

  initialSession = {
    user = "${system.mainUser}";
    command = "${environment.desktop}";
  };

  defaultSession = {
    user = "greeter";
    command = concatStringsSep " " [
      (getExe pkgs.greetd.tuigreet)
      "--time"
      "--remember"
      "--remember-user-session"
      "--asterisks"
      "--sessions '${sessionPath}'"
    ];
  };
in
{
  services.greetd = {
    enable = environment.loginManager == "greetd";
    vt = 2;
    restart = !system.autoLogin;

    settings = {
      default_session = defaultSession;

      initial_session = mkIf system.autoLogin initialSession;
    };
  };
}
