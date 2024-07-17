{
  lib,
  pkgs,
  inputs',
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optionals;
  inherit (lib.validators) isWayland;

  progs = osConfig.garden.programs;
  cfg = progs.gui.browsers.chromium;

  # chrome_pkg = if cfg.ungoogled then pkgs.ungoogled-chromium else pkgs.chromium;
  chrome_pkg = inputs'.beapkgs.packages.thorium;
in
{
  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      extensions =
        [
          "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
          "clngdbkpkpeebahjckkjfobafhncgmne" # stylus
          "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
          "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
          "jghecgabfgfdldnmbfkhmffcabddioke" # Volume Master
          "emffkefkbkpkgpdeeooapgaicgmcbolj" # Wikiwand
        ]
        ++ optionals progs.gaming.enable [
          "ngonfifpkpeefnhelnfdkficaiihklid" # ProtonDB
          "dnhpnfgdlenaccegplpojghhmaamnnfp" # Augmented Steam
        ];

      package = chrome_pkg.override {
        enableWideVine = false;

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
          ++ optionals (isWayland osConfig) [
            # Disabled because hardware acceleration doesn't work
            # when disabling --use-gl=egl, it's not gonna show any emojis
            # "--use-gl=egl"

            # Wayland
            "--ozone-platform=wayland"
            "--enable-features=UseOzonePlatform"
          ];
      };
    };
  };
}
