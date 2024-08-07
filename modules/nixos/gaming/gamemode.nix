{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;
  inherit (lib.strings) optionalString makeBinPath;

  env = config.garden.environment;

  programs = makeBinPath (builtins.attrValues { inherit (pkgs) hyprland coreutils systemd; });

  startscript = pkgs.writeShellScript "gamemode-start" ''
    ${optionalString (env.desktop == "Hyprland") ''
      export PATH=$PATH:${programs}
      export HYPRLAND_INSTANCE_SIGNATURE=$(ls -w1 /tmp/hypr | tail -1)
      hyprctl --batch 'keyword decoration:blur 0 ; keyword animations:enabled 0 ; keyword misc:vfr 0'
    ''}

    ${pkgs.libnotify}/bin/notify-send -a 'Gamemode' 'Optimizations activated'
  '';

  endscript = pkgs.writeShellScript "gamemode-end" ''
    ${optionalString (env.desktop == "Hyprland") ''
      export PATH=$PATH:${programs}
      export HYPRLAND_INSTANCE_SIGNATURE=$(ls -w1 /tmp/hypr | tail -1)
      hyprctl --batch 'keyword decoration:blur 1 ; keyword animations:enabled 1 ; keyword misc:vfr 1'
    ''}

      ${pkgs.libnotify}/bin/notify-send -a 'Gamemode' 'Optimizations deactivated'
  '';

  cfg = config.garden.programs.gaming;
in
{
  options.garden.programs.gaming.gamescope.enable = mkEnableOption "Gamescope compositing manager";

  config.programs.gamemode = mkIf cfg.enable {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        softrealtime = "auto";
        renice = 15;
      };
      custom = {
        start = startscript.outPath;
        end = endscript.outPath;
      };
    };
  };
}
