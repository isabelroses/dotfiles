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
    coreutils
    power-profiles-daemon
    systemd
  ]);

  startscript = pkgs.writeShellScript "gamemode-start" ''
    export PATH=$PATH:${programs}
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -w1 /tmp/hypr | tail -1)
    hyprctl --batch 'keyword decoration:blur 0 ; keyword animations:enabled 0 ; keyword misc:vfr 0'
    ${pkgs.libnotify}/bin/notify-send -a 'Gamemode' 'Optimizations activated'
    powerprofilesctl set performance
  '';

  endscript = pkgs.writeShellScript "gamemode-end" ''
    export PATH=$PATH:${programs}
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -w1 /tmp/hypr | tail -1)
    hyprctl --batch 'keyword decoration:blur 1 ; keyword animations:enabled 1 ; keyword misc:vfr 1'
    ${pkgs.libnotify}/bin/notify-send -a 'Gamemode' 'Optimizations deactivated'
    powerprofilesctl set power-saver
  '';

  cfg = config.modules.usrEnv.programs;
in {
  config = mkIf cfg.gaming.enable {
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

      steam = {
        enable = true;
        # Open ports in the firewall for Steam Remote Play
        remotePlay.openFirewall = true;
        # Open ports in the firewall for Source Dedicated Server
        dedicatedServer.openFirewall = true;
        # Compatibility tools to install
        # this option is provided by modules/shared/nixos/steam
        withProtonGE = true;
      };
    };
  };
}
