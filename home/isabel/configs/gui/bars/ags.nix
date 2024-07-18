{
  lib,
  pkgs,
  inputs',
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.meta) getExe;
  inherit (lib.validators) isWayland;

  inherit (osConfig.garden) programs; # environment system;
in
{
  config = mkIf (isWayland osConfig && programs.gui.bars.ags.enable) {
    home.packages = [ inputs'.ags.packages.ags ];

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

            runtimeInputs = with pkgs; [
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
              inputs'.ags.packages.default
            ];

            text = ''
              ags -c ${pkgs.callPackage ./ags-package.nix { }}/config.js
            '';
          }
        );
      };
    };

    # when testing the config, uncommenting this can be useful
    # xdg.configFile."ags" = {
    #   source = config.lib.file.mkOutOfStoreSymlink "${environment.flakePath}/home/${system.mainUser}/configs/gui/bars/ags";
    #   recursive = true;
    # };
  };
}
