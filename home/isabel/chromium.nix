{ lib, pkgs, ... }:
let
  inherit (lib.lists) concatLists;
  inherit (lib.strings) concatMapStrings enableFeature;

  features = en: features: "--${en}-features=" + (concatMapStrings (x: x + ",") features);

  extension =
    {
      id,
      version,
      hash,
    }:
    {
      inherit id version;
      crxPath = pkgs.fetchurl {
        name = "${id}.crx";
        url = "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&prodversion=149&x=id%3D${id}%26installsource%3Dondemand%26uc";
        inherit hash;
      };
    };
in
{
  programs.chromium = {
    extensions = map extension [
      # uBlock Origin
      {
        id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
        version = "1.72.0";
        hash = "sha256-b18FKOXz5mGKbIMd5TvmXz95KQ7fTT44Qzk46xGCQ/I=";
      }

      # stylus
      {
        id = "clngdbkpkpeebahjckkjfobafhncgmne";
        version = "2.4.2";
        hash = "sha256-3K3NCSJFyoY3Z5aEWNi2DWAucilJ3urHDuwSsev2Sv4=";
      }

      # Bitwarden
      {
        id = "nngceckbapebfimnlniiiahkandclblb";
        version = "2026.6.0";
        hash = "sha256-szBs8uPHBpgx4VAprSLOtD1XOAjUgecoAp6aJsvuT74=";
      }

      # at://wormhole
      {
        id = "aihndpeeoneojofmliffjknbegmipbim";
        version = "1.1.0";
        hash = "sha256-oR4q4U1R5GDjCkwwjZSMU0amR91+T1h76cpsjOxnGiM=";
      }

      # SponsorBlock
      {
        id = "mnjggcdmjocbbbhaepdhchncahnbgone";
        version = "6.1.6";
        hash = "sha256-VYf+K2qZRhAcoN3nxu/nanVcXuW21uY9/EjH9zbNtP8=";
      }

      # Volume Master
      {
        id = "jghecgabfgfdldnmbfkhmffcabddioke";
        version = "2.4.0";
        hash = "sha256-dSLS7Km/5gbb07xEYACAOs9EBfvbJGlqx4qwFkKV95U=";
      }

      # scriptcat
      {
        id = "ndcooeababalnlpkfedmmbbbgkljhpjf";
        version = "1.4.0";
        hash = "sha256-8YLHEQogwSB+EDKIFqJycj5JcGHhRZxLwxYMS22ZRZ0=";
      }

      # ff2mpv
      {
        id = "ephjcajbkgplkjmelpglennepbpmdpjg";
        version = "6.0.0";
        hash = "sha256-4VEwf3rqtobbOElIsYi1mIcIvFS3KXlpHYfs3d+AzGg=";
      }

      # Control Panel for Twitter
      {
        id = "kpmjjdhbcfebfjgdnpjagcndoelnidfj";
        version = "4.22.5";
        hash = "sha256-CmJoZ+5vsk/T8cTP0LE+oGs8EM5nlzrLWn2MzoEMldM=";
      }

      # refined github
      {
        id = "hlepfoohegkhhmjieoechaddaejaokhf";
        version = "26.6.7";
        hash = "sha256-Iht2QFqg3FixCfuX9fl4/SA9iXiK4x4t+vnlbS8Di1I=";
      }
    ];

    nativeMessagingHosts = [ pkgs.ff2mpv-rust ];

    package = pkgs.ungoogled-chromium.override {
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
          (enableFeature true "gpu-rasterization")
          (enableFeature true "oop-rasterization")
          (enableFeature true "zero-copy")

          # share a process per site
          "--process-per-site"

          # allow parallel downloads
          (enableFeature true "parallel-downloading")

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

          # hdr some others too
          (enableFeature true "experimental-web-platform-features")

          # I don't need these, thus I disable them
          (enableFeature false "speech-api")
          (enableFeature false "speech-synthesis-api")
        ]

        # Security
        [
          # Disable pings
          "--no-pings"

          # Require HTTPS for component updater
          "--component-updater=require_encryption"

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
            # needed for wayland
            "UseOzonePlatform"

            "MiddleClickAutoscroll"

            # allow manifest v2
            "AllowLegacyMV2Extensions"

            # see the performance section as to why these are added
            "AcceleratedVideoEncoder"
            "AcceleratedVideoDecodeLinuxGL"
            "VaapiOnNvidiaGPUs"
            "WaylandLinuxDrmSyncobj"

            # Enable visited link database partitioning
            "PartitionVisitedLinkDatabase"

            # Enable prefetch privacy changes
            "PrefetchPrivacyChanges"

            # Enable split cache
            "SplitCacheByNetworkIsolationKey"
            "SplitCodeCacheByNetworkIsolationKey"

            # Enable partitioning connections
            "EnableCrossSiteFlagNetworkIsolationKey"
            "HttpCacheKeyingExperimentControlGroup"
            "PartitionConnectionsByNetworkIsolationKey"

            # Enable strict origin isolation
            "StrictOriginIsolation"

            # Enable reduce accept language header
            "ReduceAcceptLanguage"

            # Enable content settings partitioning
            "ContentSettingsPartitioning"
          ])

          (features "disable" [
            # Disable autofill
            "AutofillPaymentCardBenefits"
            "AutofillPaymentCvcStorage"
            "AutofillPaymentCardBenefits"

            # Disable third-party cookie deprecation bypasses
            "TpcdHeuristicsGrants"
            "TpcdMetadataGrants"

            # Disable hyperlink auditing
            "EnableHyperlinkAuditing"

            # Disable showing popular sites
            "NTPPopularSitesBakedInContent"
            "UsePopularSitesSuggestions"

            # Disable article suggestions
            "EnableSnippets"
            "ArticlesListVisible"
            "EnableSnippetsByDse"

            # Disable content feed suggestions
            "InterestFeedV2"

            # Disable media DRM preprovisioning
            "MediaDrmPreprovisioning"

            # Disable autofill server communication
            "AutofillServerCommunication"

            # Disable new privacy sandbox features
            "PrivacySandboxSettings4"
            "BrowsingTopics"
            "BrowsingTopicsDocumentAPI"
            "BrowsingTopicsParameters"

            # Disable translate button
            "AdaptiveButtonInTopToolbarTranslate"

            # Disable detailed language settings
            "DetailedLanguageSettings"

            # Disable fetching optimization guides
            "OptimizationHintsFetching"

            # Partition third-party storage
            "DisableThirdPartyStoragePartitioningDeprecationTrial2"

            # Disable media engagement
            "PreloadMediaEngagementData"
            "MediaEngagementBypassAutoplayPolicies"

            # allow manifest v2
            "ExtensionsManifestV3Only"
            "ExtensionManifestV2Unsupported"
            "ExtensionManifestV2Disabled"
          ])
        ]
      ];
    };
  };
}
