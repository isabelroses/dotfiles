{ lib, osConfig, ... }:
let
  inherit (lib.lists) imap0;
  inherit (lib.strings) optionalString;
  inherit (builtins)
    concatStringsSep
    genList
    elemAt
    length
    ;

  inherit (osConfig.modules.device) monitors;
in
{
  wayland.windowManager.hyprland.extraConfig =
    let
      mapMonitors = concatStringsSep "\n" (
        imap0 (
          i: monitor:
          ''monitor=${monitor},${
            if monitor == "eDP-1" then "1920x1080@60" else "preferred"
          },${toString (i * 1920)}x0,1''
        ) monitors
      );

      mapMonitorsToWs = concatStringsSep "\n" (
        genList (x: ''
          workspace = ${toString (x + 1)}, monitor:${
            if (x + 1) <= 5 then
              "${elemAt monitors 0} ${if (x + 1) == 1 then ", default:true" else ""}"
            else
              "${elemAt monitors 1}"
          }
        '') 10
      );
    in
    ''
      ${mapMonitors}
      ${optionalString (length monitors != 1) "${mapMonitorsToWs}"}
      monitor=Unknown-1,disable

      # █▀▄▀█ █▀█ █░█ █▀▀
      # █░▀░█ █▄█ ▀▄▀ ██▄
      bind=$mod, M, submap, move
      submap=move

        binde = , left, movewindow, l
        binde = , right, movewindow, r
        binde = , up, movewindow, u
        binde = , down, movewindow, d
        binde = , j, movewindow, l
        binde = , l, movewindow, r
        binde = , i, movewindow, u
        binde = , k, movewindow, d

        bind=,escape,submap,reset
      submap=reset

      # █▀█ █▀▀ █▀ █ ▀█ █▀▀
      # █▀▄ ██▄ ▄█ █ █▄ ██▄
      bind=SUPER, R, submap, resize
      submap=resize

        binde = , left, resizeactive, -20 0
        binde = , right, resizeactive, 20 0
        binde = , up, resizeactive, 0 -20
        binde = , down, resizeactive, 0 20
        binde = , h, resizeactive, -20 0
        binde = , j, resizeactive, 20 0
        binde = , i, resizeactive, 0 -20
        binde = , k, resizeactive, 0 20

        bind=,escape,submap,reset
      submap=reset

      ${builtins.concatStringsSep "\n" (
        builtins.genList (
          x:
          let
            ws =
              let
                c = (x + 1) / 10;
              in
              builtins.toString (x + 1 - (c * 10));
          in
          ''
            bind = $mod, ${ws}, workspace, ${toString (x + 1)}
            bind = $mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
          ''
        ) 10
      )}
    '';
}
