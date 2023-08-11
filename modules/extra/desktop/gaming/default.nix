{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  programs = makeBinPath (with pkgs; [
    inputs.hyprland.packages.${pkgs.system}.default
    gojq
    systemd
  ]);

  startscript = pkgs.writeShellScript "gamemode-start" ''
    export PATH=$PATH:${programs}
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -w1 /tmp/hypr | tail -1)
    hyprctl --batch 'keyword decoration:blur 0 ; keyword animations:enabled 0 ; keyword misc:no_vfr 0'
    ${pkgs.libnotify}/bin/notify-send -a 'Gamemode' 'Optimizations activated'
  '';

  endscript = pkgs.writeShellScript "gamemode-end" ''
    export PATH=$PATH:${programs}
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -w1 /tmp/hypr | tail -1)
    hyprctl --batch 'keyword decoration:blur 1 ; keyword animations:enabled 1 ; keyword misc:no_vfr 1'
    ${pkgs.libnotify}/bin/notify-send -a 'Gamemode' 'Optimizations deactivated'
  '';

  cfg = config.modules.programs;
in {
  config = mkIf (cfg.gaming.enable) {
    programs.gamemode = {
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
  };
}
