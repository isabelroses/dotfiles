{ lib, pkgs, ... }:
let
  inherit (lib.lists) concatLists;
  inherit (lib.strings) concatStringsSep enableFeature;

  features = en: features: "--${en}-features=" + (concatStringsSep "," features);
in
{
  programs.chromium = {
    extensions = [
      "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin lite
      "clngdbkpkpeebahjckkjfobafhncgmne" # stylus
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
      "aihndpeeoneojofmliffjknbegmipbim" # at://wormhole
      "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
      "jghecgabfgfdldnmbfkhmffcabddioke" # Volume Master
      "ndcooeababalnlpkfedmmbbbgkljhpjf" # scriptcat
      "ephjcajbkgplkjmelpglennepbpmdpjg" # ff2mpv
      "kpmjjdhbcfebfjgdnpjagcndoelnidfj" # Control Panel for Twitter
      "hlepfoohegkhhmjieoechaddaejaokhf" # refined github
    ];

    nativeMessagingHosts = [ pkgs.ff2mpv-rust ];

    package = pkgs.chromium.override {
      enableWideVine = true;

      # https://github.com/secureblue/hardened-chromium
      # https://github.com/secureblue/secureblue/blob/e500f078efc5748d5033a881bbbcdcd2de95a813/files/system/usr/etc/chromium/chromium.conf.md
      commandLineArgs = concatLists [
        # Aesthetics
        [
          "--gtk-version=4"
          "--vertical-tabs"
        ]

        # Performance
        [
          # share a process per site
          "--process-per-site"

          # vaapi info: https://chromium.googlesource.com/chromium/src/+/refs/heads/main/docs/gpu/vaapi.md
          "--ignore-gpu-blocklist"
          "--disable-gpu-driver-bug-workaround"
        ]

        # Wayland
        [ "--ozone-platform=wayland" ]

        # Etc
        [
          "--disk-cache=$XDG_RUNTIME_DIR/chromium-cache"

          "--no-first-run"
          "--disable-wake-on-wifi"
          "--disable-breakpad"

          # please stop asking me to be the default browser
          "--no-default-browser-check"

          # stop asking me to pick a search engine on new profiles
          "--disable-search-engine-choice-screen"

          # hdr some others too
          (enableFeature true "experimental-web-platform-features")

          # middle click autoscroll is windows-only by default, force it here
          "--enable-blink-features=MiddleClickAutoscroll"

          # I don't need these, thus I disable them
          (enableFeature false "speech-api")
          (enableFeature false "speech-synthesis-api")
        ]

        # Security
        [
          # Disable pings
          "--no-pings"

          # Disable domain reliability telemetry reports
          "--disable-domain-reliability"

          # Require HTTPS for component updater
          "--component-updater=require_encryption"

          # Opt out of finch field trials / A-B experiments
          "--disable-field-trial-config"

          # Disable crash upload
          "--no-crash-upload"

          # don't run things without asking
          "--no-service-autorun"

          # Disable sync
          "--disable-sync"

          # disable canvas reading for privacy
          # (enableFeature false "reading-from-canvas")

          "--password-store=gnome-libsecret"
        ]

        [
          (features "enable" [
            # nvidia hardware encoding/decoding, these are not default
            "AcceleratedVideoEncoder"
            "AcceleratedVideoDecodeLinuxGL"
            "VaapiOnNvidiaGPUs"

            # Enable visited link database partitioning
            "PartitionVisitedLinkDatabase"

            # Enable split cache
            "SplitCacheByNetworkIsolationKey"
            "SplitCodeCacheByNetworkIsolationKey"
            "SplitAuthCacheByNetworkIsolationKey"

            # Enable partitioning connections
            "PartitionConnectionsByNetworkIsolationKey"

            # Enable strict origin isolation
            "StrictOriginIsolation"

            # Enable reduce accept language header
            "ReduceAcceptLanguage"

            # Require permission prompts for WebRTC local network access,
            # blocks sites from probing the LAN via WebRTC by default
            "LocalNetworkAccessChecksWebRTC"

            # Make ORB-blocked responses error out for script-initiated
            # fetches instead of returning empty successes
            "OpaqueResponseBlockingErrorsForAllFetches"
          ])

          (features "disable" [
            # Disable autofill
            "AutofillPaymentCardBenefits"
            "AutofillPaymentCvcStorage"

            # Disable third-party cookie deprecation bypasses
            "TpcdHeuristicsGrants"

            # Disable hyperlink auditing
            "EnableHyperlinkAuditing"

            # Disable article suggestions
            "EnableSnippets"

            # Disable autofill server communication
            "AutofillServerCommunication"

            # Disable new privacy sandbox features
            "BrowsingTopics"
            "BrowsingTopicsParameters"

            # Disable privacy sandbox ad APIs entirely
            "Fledge"
            "AttributionReporting"

            # Disable fetching optimization guide models
            "OptimizationHints"
            "OptimizationHintsFetching"

            # Disable the cast service, stops mDNS discovery chatter on the LAN
            # NOTE: this removes the Cast menu entry
            "MediaRouter"

            # Stop websites from auto-adjusting the microphone input volume
            "WebRtcAllowInputVolumeAdjustment"

            # Disable media engagement
            "PreloadMediaEngagementData"
            "MediaEngagementBypassAutoplayPolicies"
          ])
        ]
      ];
    };
  };
}
