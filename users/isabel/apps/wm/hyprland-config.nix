{
    config,
    isNvidia,
    isLaptop,
    ...
}:
with lib; let
    cfg = config.isabel.hyprland;
in {
    wayland.windowManager.hyprland = mkMerge [
        (mkIf cfg.enable {
            extraConfig = ''
                # █░█ ▄▀█ █▀█ █ ▄▀█ █▄▄ █░░ █▀▀ █▀
                # ▀▄▀ █▀█ █▀▄ █ █▀█ █▄█ █▄▄ ██▄ ▄█
                $teal      = 0xff94e2d5
                $sky       = 0xff89dceb
                $sapphire  = 0xff74c7ec
                $blue      = 0xff89b4fa
                $surface1  = 0xff45475a
                $surface0  = 0xff313244

                $term=alacritty
                $browser=chromium
                $file=thunar
                $editor=code
                $notes=obsidian
                $layout=dwindle
                $mod=SUPER

                # █▀▀ ▀▄▀ █▀▀ █▀▀
                # ██▄ █░█ ██▄ █▄▄
                exec-once = wl-paste --type text --watch cliphist store #Stores only text data
                exec-once = wl-paste --type image --watch cliphist store #Stores only image data
                # exec-once = wlsunset -S 9:00 -s 19:30
                exec-once = bash ~/.config/eww/scripts/init
                exec-once = hyprctl setcursor Catppuccin-Mocha-Sapphire 24
                
                # █▀▀ █▀▀ █▄░█ █▀▀ █▀█ ▄▀█ █░░
                # █▄█ ██▄ █░▀█ ██▄ █▀▄ █▀█ █▄▄
                general {
                    gaps_in=5
                    gaps_out=5
                    border_size=2
                    no_border_on_floating = true
                    layout = $layout
                    col.active_border=$sapphire
                    col.inactive_border=$surface0
                    col.group_border_active=$blue
                    col.group_border=$surface0
                }

                # █▀▄▀█ █ █▀ █▀▀
                # █░▀░█ █ ▄█ █▄▄
                misc {
                    disable_hyprland_logo = true
                    disable_splash_rendering = true
                    mouse_move_enables_dpms = true
                    enable_swallow = true
                }

                # █▀▄ █▀▀ █▀▀ █▀█ █▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█
                # █▄▀ ██▄ █▄▄ █▄█ █▀▄ █▀█ ░█░ █ █▄█ █░▀█

                decoration {
                    # █▀█ █▀█ █░█ █▄░█ █▀▄   █▀▀ █▀█ █▀█ █▄░█ █▀▀ █▀█
                    # █▀▄ █▄█ █▄█ █░▀█ █▄▀   █▄▄ █▄█ █▀▄ █░▀█ ██▄ █▀▄
                    rounding = 10
                    multisample_edges = true

                    # █▀█ █▀█ ▄▀█ █▀▀ █ ▀█▀ █▄█
                    # █▄█ █▀▀ █▀█ █▄▄ █ ░█░ ░█░
                    active_opacity = 1.0
                    inactive_opacity = 1.0

                    # █▄▄ █░░ █░█ █▀█
                    # █▄█ █▄▄ █▄█ █▀▄
                    blur = true
                    blur_passes = 1
                    blur_size = 2
                    blur_new_optimizations = true
                    blurls = "eww_powermenu"
                    blurls = "eww_takeshot"

                    # █▀ █░█ ▄▀█ █▀▄ █▀█ █░█░█
                    # ▄█ █▀█ █▀█ █▄▀ █▄█ ▀▄▀▄▀
                    drop_shadow = true
                    col.shadow=$surface1
                    col.shadow_inactive=$surface1
                }

                # █░░ ▄▀█ █▄█ █▀█ █░█ ▀█▀ █▀
                # █▄▄ █▀█ ░█░ █▄█ █▄█ ░█░ ▄█

                master {
                    no_gaps_when_only = false
                    new_is_master = true
                }

                dwindle {
                    no_gaps_when_only = false
                    pseudotile = true
                    preserve_split = true
                }

                # █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█   █▀█ █░█ █░░ █▀▀ █▀
                # ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀   █▀▄ █▄█ █▄▄ ██▄ ▄█
                windowrule = float, ^(Rofi)$
                windowrule = float, ^(eww)$
                windowrule = float, ^(pavucontrol)$
                windowrule = float, ^(nm-connection-editor)$
                windowrule = float, ^(blueberry.py)$
                windowrule = float, ^(org.gnome.Settings)$
                windowrule = float, ^(org.gnome.design.Palette)$
                windowrule = float, ^(Color Picker)$
                windowrule = float, ^(Network)$
                windowrule = float, ^(xdg-desktop-portal)$
                windowrule = float, ^(xdg-desktop-portal-gnome)$
                windowrule = float, ^(transmission-gtk)$
                windowrule=workspace 6 silent,discord

                # █▄▀ █▀▀ █▄█ █▄▄ █ █▄░█ █▀▄
                # █░█ ██▄ ░█░ █▄█ █ █░▀█ █▄▀

                bind = $mod, B, exec, $browser
                bind = $mod, E, exec, $file
                bind = $mod, C, exec, $editor
                bind = $mod, Return, exec, $term
                bind = $mod, O, exec, $notes
                bind = $mod, D, exec, ~/.config/eww/scripts/launcher toggle_menu app_launcher
                bind = $mod SHIFT, R, exec, ~/.config/eww/scripts/init
                #bind = $mod, period, exec, killall rofi || rofi -show emoji -emoji-format "{emoji}" -modi emoji
                bind = $mod, V, exec, ~/.config/eww/scripts/launcher clipboard
                bind = $mod, F1, exec, ~/.config/hypr/keybind
                bind = $mod, escape, exec, ~/./.config/eww/scripts/launcher toggle_menu powermenu

                # █▀ █▀▀ █▀█ █▀▀ █▀▀ █▄░█ █▀ █░█ █▀█ ▀█▀
                # ▄█ █▄▄ █▀▄ ██▄ ██▄ █░▀█ ▄█ █▀█ █▄█ ░█░
                bind = , PRINT, exec, ~/.config/eww/scripts/launcher toggle_menu takeshot
                bind = SHIFT, PRINT, exec, ~/.config/eww/scripts/screenshot screen-quiet
                bind = SUPER SHIFT, S, exec, ~/.config/eww/scripts/screenshot area-quiet

                # █▀▄▀█ █ █▀ █▀▀
                # █░▀░█ █ ▄█ █▄▄
                # bind = $mod, X, exec, hyprpicker -a -n
                bind = , XF86AudioMute, exec, ~/.config/eww/scripts/volume mute
                bind = , XF86AudioRaiseVolume, exec, ~/.config/eww/scripts/volume up
                bind = , XF86AudioLowerVolume, exec, ~/.config/eww/scripts/volume down
                bind = , XF86MonBrightnessUp, exec, ~/.config/eww/scripts/brightness up
                bind = , XF86MonBrightnessDown, exec, ~/.config/eww/scripts/brightness down
                bind = , XF86AudioPlay, exec, playerctl play-pause
                bind = , XF86AudioPause, exec, playerctl play-pause
                bind = , XF86AudioNext, exec, playerctl next
                bind = , XF86AudioPrev, exec, playerctl previous
                bind = $mod, Tab, cyclenext,
                bind = $mod, Tab, bringactivetotop,
                bind = $mod, L, exec, ~/.config/eww/scripts/launcher screenlock

                # █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█   █▀▄▀█ ▄▀█ █▄░█ ▄▀█ █▀▀ █▀▄▀█ █▀▀ █▄░█ ▀█▀
                # ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀   █░▀░█ █▀█ █░▀█ █▀█ █▄█ █░▀░█ ██▄ █░▀█ ░█░
                bind = $mod, Q, killactive,
                # bind = $mod SHIFT, Q, exit,
                bind = $mod SHIFT, c, exec, hyprctl reload
                bind = $mod, F, fullscreen,
                bind = $mod, Space, togglefloating,
                bind = $mod, P, pseudo, # dwindle
                bind = $mod, S, togglesplit, # dwindle

                # █▀▀ █▀█ █▀▀ █░█ █▀
                # █▀░ █▄█ █▄▄ █▄█ ▄█
                bind = $mod, left, movefocus, l
                bind = $mod, right, movefocus, r
                bind = $mod, up, movefocus, u
                bind = $mod, down, movefocus, d

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

                # ▀█▀ ▄▀█ █▄▄ █▄▄ █▀▀ █▀▄
                # ░█░ █▀█ █▄█ █▄█ ██▄ █▄▀
                bind= $mod, g, togglegroup
                bind= $mod, tab, changegroupactive

                # █▀ █▀█ █▀▀ █▀▀ █ ▄▀█ █░░
                # ▄█ █▀▀ ██▄ █▄▄ █ █▀█ █▄▄
                # bind = $mod, grave, togglespecialworkspace
                # bind = $modSHIFT, grave, movetoworkspace, special

                # █▀ █░█░█ █ ▀█▀ █▀▀ █░█
                # ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█
                bind = $mod, 1, workspace, 1
                bind = $mod, 2, workspace, 2
                bind = $mod, 3, workspace, 3
                bind = $mod, 4, workspace, 4
                bind = $mod, 5, workspace, 5
                bind = $mod, 6, workspace, 6
                bind = $mod, 7, workspace, 7
                bind = $mod, 8, workspace, 8
                bind = $mod, 9, workspace, 9
                bind = $mod, 0, workspace, 10
                bind = $mod ALT, up, workspace, e+1
                bind = $mod ALT, down, workspace, e-1

                # █▀▄▀█ █▀█ █░█ █▀▀
                # █░▀░█ █▄█ ▀▄▀ ██▄
                bind = $mod SHIFT, 1, movetoworkspace, 1
                bind = $mod SHIFT, 2, movetoworkspace, 2
                bind = $mod SHIFT, 3, movetoworkspace, 3
                bind = $mod SHIFT, 4, movetoworkspace, 4
                bind = $mod SHIFT, 5, movetoworkspace, 5
                bind = $mod SHIFT, 6, movetoworkspace, 6
                bind = $mod SHIFT, 7, movetoworkspace, 7
                bind = $mod SHIFT, 8, movetoworkspace, 8
                bind = $mod SHIFT, 9, movetoworkspace, 9
                bind = $mod SHIFT, 0, movetoworkspace, 10

                # █▀▄▀█ █▀█ █░█ █▀ █▀▀   █▄▄ █ █▄░█ █▀▄ █ █▄░█ █▀▀
                # █░▀░█ █▄█ █▄█ ▄█ ██▄   █▄█ █ █░▀█ █▄▀ █ █░▀█ █▄█
                bindm = $mod, mouse:272, movewindow
                bindm = $mod, mouse:273, resizewindow
                bind = $mod, mouse_down, workspace, e+1
                bind = $mod, mouse_up, workspace, e-1
            '';
        })
        (mkIf (cfg.enable && cfg.isNvidia) {
            extraConfig = ''
                # █▀▄▀█ █▀█ █▄░█ █ ▀█▀ █▀█ █▀█
                # █░▀░█ █▄█ █░▀█ █ ░█░ █▄█ █▀▄
                monitor = ,1920x1080@60,0x0,1

                # █ █▄░█ █▀█ █░█ ▀█▀
                # █ █░▀█ █▀▀ █▄█ ░█░
                input {
                    kb_layout = us
                    follow_mouse = 1
                    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
                }

                # ▄▀█ █▄░█ █ █▀▄▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█
                # █▀█ █░▀█ █ █░▀░█ █▀█ ░█░ █ █▄█ █░▀█
                animations {
                    enabled = true
                    bezier=overshot,0.05,0.9,0.1,1.1

                    animation=windows,1,8,overshot,popin
                    # animation=fade,1,8,overshot
                    animation=workspaces,1,8,overshot,slide
                }
            '';
        })
        (mkIf (cfg.enable && cfg.isLaptop) {
            extraConfig = ''
                # █▀▄▀█ █▀█ █▄░█ █ ▀█▀ █▀█ █▀█
                # █░▀░█ █▄█ █░▀█ █ ░█░ █▄█ █▀▄
                monitor = ,1920x1080@60,0x0,1

                # █ █▄░█ █▀█ █░█ ▀█▀
                # █ █░▀█ █▀▀ █▄█ ░█░
                input {
                    kb_layout = gb
                    follow_mouse = 1
                    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
                    touchpad {
                        tap-to-click = true
                        natural_scroll = true
                        disable_while_typing = false
                    }
                }
                gestures {
                    workspace_swipe = true
                }
                animations {
                    enabled = false
                }
            '';
        })
    ];
}