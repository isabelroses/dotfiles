{
  lib,
  pkgs,
  config,
  inputs',
  ...
}:
let
  inherit (lib) mkIf;
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
{
  config = mkIf config.garden.profiles.media.watching.enable {
    garden.packages = mkIf pkgs.stdenv.hostPlatform.isLinux {
      inherit (pkgs)
        syncplay
        yt-dlp
        ffmpeg
        playerctl
        ;

      inherit (inputs'.tgirlpkgs.packages) tidaluna;
    };

    # i don't really like it LOL
    catppuccin.mpv.enable = false;

    programs.mpv = {
      enable = true;

      scripts =
        (with pkgs.mpvScripts; [
          videoclip
          sponsorblock

          # modern ui
          modernz
          thumbfast

          # mpv as our image viewer
          mpv-image-viewer.image-positioning
        ])
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          pkgs.mpvScripts.mpris
        ];

      bindings = {
        # sane defaults
        "AXIS_UP" = "add volume 2";
        "AXIS_DOWN" = "add volume -2";
        "UP" = "add volume 2";
        "DOWN" = "add volume -2";
        "Shift+RIGHT" = "frame-step";
        "Shift+LEFT" = "frame-back-step";
        "Shift+UP" = "add volume 10";
        "Shift+DOWN" = "add volume -10";
        "y" = "cycle deband";
        "z" = "cycle deband";
        "ctrl+d" = "vf toggle yadif";
        "e" = "add sub-delay +0.042";
        "w" = "add sub-delay -0.042";
        "b" = "add audio-delay +0.042";
        "n" = "add audio-delay -0.042";
        "a" = "cycle-values video-aspect \"16:9\" \"4:3\" \"2.35:1\" \"-1\"";

        # videoclip script
        "c" = "script-binding videoclip-menu-open";

        # mpv as a image viewer
        MBTN_RIGHT = "script-binding drag-to-pan";
        "alt+down" = "repeatable script-message pan-image y -0.01 yes yes";
        "alt+up" = "repeatable script-message pan-image y +0.01 yes yes";
        "alt+right" = "repeatable script-message pan-image x -0.01 yes yes";
        "alt+left" = "repeatable script-message pan-image x +0.01 yes yes";
      };

      config = {
        # osc settings
        osc = "no"; # i am using modernz ^.^
        border = "no";
        msg-color = "yes";
        msg-module = "yes";

        save-watch-history = "yes";

        #  audio settings
        volume-max = 200;

        # video settings
        # use hardware decoding when available, prefer vulkan
        hwdec = if isLinux then "auto-copy" else "auto";
        gpu-api = if isLinux then "vulkan" else "auto";
        profile = "gpu-hq";
        vo = "gpu-next"; # GPU-Next: https://github.com/mpv-player/mpv/wiki/GPU-Next-vs-GPV

        # screenshot settings
        screenshot-directory = "~/media/pictures/screenshots";
        screenshot-template = "%x/screenshot-%F-T%wH.%wM.%wS.%wT-F%{estimated-frame-number}";
        screenshot-format = "png";
        screenshot-png-compression = 4; # Range is 0 to 10. 0 being no compression.
        screenshot-tag-colorspace = "yes";
        screenshot-high-bit-depth = "yes"; # Same output bitdepth as the video

        # use English audio and subtitles if available
        alang = "jpn,jp,en";
        slang = "eng,en";

        # misc
        stop-screensaver = "yes";
        cursor-autohide = 100; # auto hide cursor after 100ms
        reset-on-next-file = "video-zoom,panscan,video-unscaled,video-rotate,video-align-x,video-align-y";
      };

      profiles = {
        image = {
          profile-cond = "p[\"current-tracks/video\"] and p[\"current-tracks/video\"].image and not p[\"current-tracks/video\"].albumart";
          profile-restore = "copy-equal";

          # we need duplicate config options which nix doesn't really handle
          include = toString (
            pkgs.writeText "mpv-image-viewer.conf" ''
              script-opts-append=modernz-fade_alpha=50
              script-opts-append=modernz-window_title=yes
              script-opts-append=modernz-bottomhover_zone=50
            ''
          );

          title = "\${media-title} [\${?width:\${width}x\${height}}]";
          taskbar-progress = "no";
          video-unscaled = "yes";
          video-recenter = "yes";
          window-dragging = "no";

          prefetch-playlist = "yes";
          video-aspect-override = "no";

          # keep the file open
          loop-file = "inf";
          image-display-duration = "inf";
          loop-playlist = "inf";
        };

        # good refrences for mpv config:
        # <https://github.com/Tsubajashi/mpv-settings>
        video = {
          profile-cond = "p[\"current-tracks/video\"] and not p[\"current-tracks/video\"].image";
          profile-restore = "copy-equal";
          taskbar-progress = "yes";
        };
      };

      scriptOpts = {
        modernz = {
          idlescreen = "no";
          download_path = "~/media/videos";

          # change some buttons
          ontop_button = "no";
          speed_button = "yes";
          info_button = "no";
          fullscreen_button = "no";

          hover_effect = "color";
          hover_effect_color = "#74c7ec";
          seekbarfg_color = "#74c7ec";
          seekbarbg_color = "#181825";
        };

        videoclip = {
          video_folder_path = "~/media/videos";
          audio_folder_path = "~/media/music";
        };
      };
    };
  };
}
