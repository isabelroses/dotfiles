{ lib, osConfig, ... }:
let
  inherit (lib.lists) imap0;
  inherit (lib.strings) optionalString concatLines;
  inherit (builtins)
    genList
    elemAt
    length
    ;

  inherit (osConfig.garden.device) monitors;
in
{
  wayland.windowManager.hyprland.extraConfig =
    let
      mapMonitors = concatLines (
        imap0 (
          i: monitor:
          ''monitor=${monitor},${
            if monitor == "eDP-1" then "1920x1080@60" else "preferred"
          },${toString (i * 1920)}x0,1''
        ) monitors
      );

      mapMonitorsToWs = concatLines (
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

      # █▀▀ █▀█ █▀▀ █░█ █▀
      # █▀░ █▄█ █▄▄ █▄█ ▄█
      bind = SUPER, left, movefocus, l
      bind = SUPER, right, movefocus, r
      bind = SUPER, up, movefocus, u
      bind = SUPER, down, movefocus, d

      # █▀▄▀█ █▀█ █░█ █▀▀
      # █░▀░█ █▄█ ▀▄▀ ██▄

      bind = SUPER SHIFT, left, movewindow, l
      bind = SUPER SHIFT, right, movewindow, r
      bind = SUPER SHIFT, up, movewindow, u
      bind = SUPER SHIFT, down, movewindow, d
      bind = SUPER SHIFT, h, movewindow, l
      bind = SUPER SHIFT, j, movewindow, d
      bind = SUPER SHIFT, k, movewindow, u
      bind = SUPER SHIFT, l, movewindow, r

      # █▀▄▀█ █▀█ █░█ █▀▀
      # █░▀░█ █▄█ ▀▄▀ ██▄
      bind=SUPER SHIFT, M, submap, move-monitor
      submap=move-monitor

        bind = , left, movecurrentworkspacetomonitor, l
        bind = , right, movecurrentworkspacetomonitor, r
        bind = , up, movecurrentworkspacetomonitor, u
        bind = , down, movecurrentworkspacetomonitor, d
        bind = , h, movecurrentworkspacetomonitor, l
        bind = , j, movecurrentworkspacetomonitor, d
        bind = , k, movecurrentworkspacetomonitor, u
        bind = , l, movecurrentworkspacetomonitor, r

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
    '';
}
