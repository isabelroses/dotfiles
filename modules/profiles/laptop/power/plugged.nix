{
  pkgs,
  lib,
  inputs',
  ...
}: let
  programs = lib.makeBinPath [inputs'.hyprland.packages.default];
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
