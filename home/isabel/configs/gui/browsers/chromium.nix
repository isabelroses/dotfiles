{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  progs = osConfig.modules.programs;
  cfg = progs.gui.browsers.chromium;

  chrome_pkg = if cfg.ungoogled then pkgs.ungoogled-chromium else pkgs.chromium;
in
{
  config = lib.mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      extensions =
        [
          "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
          "clngdbkpkpeebahjckkjfobafhncgmne" # stylus
          "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
          "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
          "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
          "jghecgabfgfdldnmbfkhmffcabddioke" # Volume Master
          "emffkefkbkpkgpdeeooapgaicgmcbolj" # Wikiwand
          "jaoafjdoijdconemdmodhbfpianehlon" # skip redirect
        ]
        ++ lib.optionals progs.gaming.enable [
          "ngonfifpkpeefnhelnfdkficaiihklid" # ProtonDB
          "dnhpnfgdlenaccegplpojghhmaamnnfp" # Augmented Steam
        ];

      # extraOpts = {
      #   "AutofillAddressEnabled" = false;
      #   "AutofillCreditCardEnabled" = false;
      #   "BuiltInDnsClientEnabled" = false;
      #   "DeviceMetricsReportingEnabled" = true;
      #   "ReportDeviceCrashReportInfo" = false;
      #   "PasswordManagerEnabled" = false;
      #   "SpellcheckEnabled" = true;
      #   "SpellcheckLanguage" = [
      #     "en-GB"
      #     "en-US"
      #   ];
      #   "VoiceInteractionHotwordEnabled" = false;
      # };

      package = chrome_pkg.override {
        nss = pkgs.nss_latest;
        enableWideVine = true;

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
          ++ lib.optionals (lib.isWayland osConfig) [
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
