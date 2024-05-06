{
  lib,
  pkgs,
  ...
}: let
  programs = lib.makeBinPath [pkgs.hyprland];
in {
  unplugged = pkgs.writeShellScript "unplugged" ''
    export PATH=$PATH:${programs}
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -w1 /tmp/hypr | tail -1)

    systemctl --user --machine=1000@ stop easyeffects nextcloud
    hyprctl --batch 'keyword decoration:drop_shadow 0'
  '';

  plugged = pkgs.writeShellScript "plugged" ''
    export PATH=$PATH:${programs}
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -w1 /tmp/hypr | tail -1)

    systemctl --user --machine=1000@ start easyeffects nextcloud
    hyprctl --batch 'keyword decoration:drop_shadow 1'
    cpupower frequency-set -g performance
  '';
}
