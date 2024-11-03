{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.meta) getExe;
  inherit (lib.strings) concatStringsSep;
  inherit (lib.options) mkOption;
  inherit (lib.types) bool;

  inherit (config.garden) system environment;

  sessionData = config.services.displayManager.sessionData.desktops;
  sessionPath = concatStringsSep ":" [
    "${sessionData}/share/xsessions"
    "${sessionData}/share/wayland-sessions"
  ];
in
{
  options.garden.system.autoLogin = mkOption {
    type = bool;
    default = false;
    description = ''
      Whether to enable passwordless login. This is generally useful on systems with
      FDE (Full Disk Encryption) enabled. It is a security risk for systems without FDE.
    '';
  };

  config.services.greetd = mkIf (environment.loginManager == "greetd") {
    enable = true;
    vt = 2;
    restart = !system.autoLogin;

    settings = {
      default_session = {
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

      initial_session = mkIf system.autoLogin {
        user = "${system.mainUser}";
        command = "${environment.desktop}";
      };
    };
  };
}
