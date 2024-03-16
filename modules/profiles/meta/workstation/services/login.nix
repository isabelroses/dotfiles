{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (config.modules) system environment;
  inherit (lib) mkIf getExe concatStringsSep;

  sessionData = config.services.xserver.displayManager.sessionData.desktops;
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
in {
  config = {
    # unlock GPG keyring on login
    security.pam.services = let
      login = {
        enableGnomeKeyring = true;
        gnupg = {
          enable = true;
          noAutostart = true;
          storeOnly = true;
        };
      };
    in {
      inherit login;

      greetd = mkIf (environment.loginManager == "greetd") login;

      tuigreet = login;
    };

    services = {
      greetd = {
        enable = environment.loginManager == "greetd";
        vt = 2;
        restart = !system.autoLogin;

        settings = {
          default_session = defaultSession;

          initial_session = mkIf system.autoLogin initialSession;
        };
      };

      logind = {
        lidSwitch = "ignore";
        lidSwitchDocked = "ignore";
        lidSwitchExternalPower = "ignore";
        powerKey = "suspend-then-hibernate";
      };
    };
  };
}
