{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (config.modules) system environment;
  inherit (lib)
    mkIf
    getExe
    concatStringsSep
    mkOption
    types
    ;

  sessionData = config.services.displayManager.sessionData.desktops;
  sessionPath = concatStringsSep ":" [
    "${sessionData}/share/xsessions"
    "${sessionData}/share/wayland-sessions"
  ];
in
{
  options.modules.system.autoLogin = mkOption {
    type = types.bool;
    default = false;
    description = ''
      Whether to enable passwordless login. This is generally useful on systems with
      FDE (Full Disk Encryption) enabled. It is a security risk for systems without FDE.
    '';
  };

  services.greetd = {
    enable = environment.loginManager == "greetd";
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
