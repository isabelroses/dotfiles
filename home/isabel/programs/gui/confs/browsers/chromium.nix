{
  lib,
  pkgs,
  osConfig,
  defaults,
  ...
}: let
  inherit (lib) mkIf optionals;
  inherit (osConfig.modules) device programs;
  sys = osConfig.modules.system;
  env = osConfig.modules.usrEnv;
  acceptedTypes = ["laptop" "desktop" "hybrid"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes && programs.gui.enable && sys.video.enable && defaults.browser == "chromium") {
    programs.chromium = {
      enable = true;
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        "clngdbkpkpeebahjckkjfobafhncgmne" # stylus
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
        "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
        "jghecgabfgfdldnmbfkhmffcabddioke" # Volume Master
        "emffkefkbkpkgpdeeooapgaicgmcbolj" # Wikiwand
      ];
      package = pkgs.chromium.override {
        nss = pkgs.nss_latest;
        commandLineArgs =
          [
            # Aesthetics
            "--force-dark-mode"

            # Performance
            "--enable-gpu-rasterization"
            "--enable-oop-rasterization"
            "--enable-zero-copy"
            "--ignore-gpu-blocklist"

            # Etc
            # "--gtk-version=4"
            "--disk-cache=$XDG_RUNTIME_DIR/chromium-cache"
            "--no-default-browser-check"
            "--no-service-autorun"
            "--disable-features=PreloadMediaEngagementData,MediaEngagementBypassAutoplayPolicies"
            "--disable-reading-from-canvas"
            "--no-pings"
            "--no-first-run"
            "--no-experiments"
            "--no-crash-upload"
            "--disable-wake-on-wifi"
            "--disable-breakpad"
            "--disable-sync"
            "--disable-speech-api"
            "--disable-speech-synthesis-api"
          ]
          ++ optionals (env.isWayland) [
            # Wayland
            # Disabled because hardware acceleration doesn't work
            # when disabling --use-gl=egl, it's not gonna show any emoji
            # and it's gonna be slow as hell

            # "--use-gl=egl"

            "--ozone-platform=wayland"
            "--enable-features=UseOzonePlatform"
          ];
      };
    };
  };
}
