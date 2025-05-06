{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    getExe
    mkOption
    mkOptionDefault
    concatStringsSep
    ;
  inherit (lib.types) nullOr enum;

  sessionData = config.services.displayManager.sessionData.desktops;
  sessionPath = concatStringsSep ":" [
    "${sessionData}/share/xsessions"
    "${sessionData}/share/wayland-sessions"
  ];

  cfg = config.garden.environment.loginManager;
in
{
  options.garden.environment.loginManager = mkOption {
    type = nullOr (enum [
      "greetd"
      "cosmic-greeter"
    ]);
    description = "The login manager to be used by the system.";
  };

  config = mkMerge [
    {
      garden.environment.loginManager = mkOptionDefault (
        if config.garden.profiles.graphical.enable then "greetd" else null
      );
    }

    (mkIf (cfg == "greetd") {
      services.greetd = {
        enable = true;
        vt = 2;
        restart = true;

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
        };
      };
    })

    (mkIf (cfg == "cosmic-greeter") {
      services.displayManager.cosmic-greeter.enable = true;
    })
  ];
}
