{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) makeBinPath mkIf optionalString;

  env = config.modules.usrEnv;

  programs = makeBinPath (with pkgs; [
    inputs.hyprland.packages.${stdenv.system}.default
    coreutils
    power-profiles-daemon
    systemd
  ]);

  startscript = pkgs.writeShellScript "gamemode-start" ''
    ${optionalString (env.desktop == "Hyprland") ''
      export PATH=$PATH:${programs}
      export HYPRLAND_INSTANCE_SIGNATURE=$(ls -w1 /tmp/hypr | tail -1)
      hyprctl --batch 'keyword decoration:blur 0 ; keyword animations:enabled 0 ; keyword misc:vfr 0'
    ''}

    powerprofilesctl set performance
    ${pkgs.libnotify}/bin/notify-send -a 'Gamemode' 'Optimizations activated'
  '';

  endscript = pkgs.writeShellScript "gamemode-end" ''
    ${optionalString (env.desktop == "Hyprland") ''
      export PATH=$PATH:${programs}
      export HYPRLAND_INSTANCE_SIGNATURE=$(ls -w1 /tmp/hypr | tail -1)
      hyprctl --batch 'keyword decoration:blur 1 ; keyword animations:enabled 1 ; keyword misc:vfr 1'
    ''}

      powerprofilesctl set power-saver
      ${pkgs.libnotify}/bin/notify-send -a 'Gamemode' 'Optimizations deactivated'
  '';

  cfg = config.modules.programs.gaming;
in {
  imports = [./steam.nix];
  config = mkIf cfg.enable {
    programs = {
      gamemode = {
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
  };
}
