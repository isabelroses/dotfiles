{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.meta) getExe;
  inherit (lib.validators) isWayland;

  cfg = config.garden.programs.ags;
in
{
  config = mkIf (isWayland osConfig && cfg.enable) {
    home.packages = [ cfg.package ];

    systemd.user.services.ags = {
      Install.WantedBy = [ "graphical-session.target" ];

      Unit = {
        Description = "ags, our bar";
        After = [ "graphical-session-pre.target" ];
        PartOf = [
          "tray.target"
          "graphical-session.target"
        ];
      };

      Service = {
        Restart = "always";
        ExecStart = getExe (
          pkgs.writeShellApplication {
            name = "ags-config-service-script";

            runtimeInputs = builtins.attrValues {
              inherit (pkgs)
                dart-sass
                swww
                fd
                brightnessctl
                slurp
                wl-clipboard
                swappy
                hyprpicker
                pwvucontrol
                which
                ags
                ;
            };

            text = ''
              ags -c ${pkgs.callPackage ./ags-package.nix { }}/config.js
            '';
          }
        );
      };
    };

    # when testing the config, uncommenting this can be useful
    # xdg.configFile."ags" = {
    #   source = config.lib.file.mkOutOfStoreSymlink "${environment.flakePath}/home/${system.mainUser}/packages/gui/bars/ags";
    #   recursive = true;
    # };
  };
}
