{ lib, pkgs, ... }:
let
  inherit (lib.lists) optionals;
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
pkgs.mpv.override {
  scripts =
    (with pkgs.mpvScripts; [
      sponsorblock

      # unify my clipboard
      (videoclip.override { wl-clipboard = pkgs.wl-clipboard-rs; })

      # modern ui
      modernz
      thumbfast

      # mpv as our image viewer
      mpv-image-viewer.image-positioning
    ])
    ++ optionals isLinux [
      pkgs.mpvScripts.mpris
    ];

  extraUmpvWrapperArgs = [
    "--input-conf"

    "--include"
    (lib.generators.toINIWithGlobalSection { listsAsDuplicateKeys = true; } {
      globalSection = {
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
        screenshot-directory =
          if pkgs.stdenv.hostPlatform.isDarwin then
            "~/Pictures/screenshots"
          else
            "~/media/pictures/screenshots";
        screenshot-template = "%x/screenshot-%F-T%wH.%wM.%wS.%wT-F%{estimated-frame-number}";
        screenshot-format = "png";
        screenshot-png-compression = 4; # Range is 0 to 10. 0 being no compression.
        screenshot-tag-colorspace = "yes";
        screenshot-high-bit-depth = "yes"; # Same output bitdepth as the video

        # use English audio and subtitles if available
        alang = "en,jpn,jp";

        # misc
        stop-screensaver = "yes";
        cursor-autohide = 100; # auto hide cursor after 100ms
        reset-on-next-file = "video-zoom,panscan,video-unscaled,video-rotate,video-align-x,video-align-y";
        ytdl-raw-options = "cookies=~/documents/yt-dlp-cookies.txt";
      };

      sections = {
        image = {
          profile-cond = "p[\"current-tracks/video\"] and p[\"current-tracks/video\"].image and not p[\"current-tracks/video\"].albumart";
          profile-restore = "copy-equal";

          # we need duplicate config options which nix doesn't really handle
          script-opts-append = [
            "modernz-fade_alpha=50"
            "modernz-window_title=yes"
            "modernz-bottomhover_zone=50"
          ];

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
    })
  ];
}
