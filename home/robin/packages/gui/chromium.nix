{
  lib,
  self,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optionals concatLists;
  inherit (lib.strings) concatMapStrings enableFeature;
  inherit (self.lib.validators) isWayland;

  cfg = config.garden.programs.chromium;
in
{
  programs.chromium = mkIf cfg.enable {
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
      ++ optionals osConfig.garden.programs.gaming.enable [
        "ngonfifpkpeefnhelnfdkficaiihklid" # ProtonDB
        "dnhpnfgdlenaccegplpojghhmaamnnfp" # Augmented Steam
      ];

    package = cfg.package.override {
      enableWideVine = true;

      # https://github.com/secureblue/hardened-chromium
      # https://github.com/secureblue/secureblue/blob/e500f078efc5748d5033a881bbbcdcd2de95a813/files/system/usr/etc/chromium/chromium.conf.md
      commandLineArgs = concatLists [
        # Aesthetics
        [
          "--force-dark-mode"
          "--gtk-version=4"
        ]

        # Performance
        [
          (enableFeature true "gpu-rasterization")
          (enableFeature true "oop-rasterization")
          (enableFeature true "zero-copy")
          "--ignore-gpu-blocklist"
        ]

        # Wayland
        (optionals (isWayland osConfig) [
          "--ozone-platform=wayland"
          "--enable-features=UseOzonePlatform"
        ])

        # Etc
        [
          "--disk-cache=$XDG_RUNTIME_DIR/chromium-cache"
          (enableFeature false "reading-from-canvas")
          "--no-first-run"
          "--disable-wake-on-wifi"
          "--disable-breakpad"

          # please stop asking me to be the default browser
          "--no-default-browser-check"

          # I don't need these, thus I disable them
          (enableFeature false "speech-api")
          (enableFeature false "speech-synthesis-api")
        ]

        # Security
        [
          # Use strict extension verification
          "--extension-content-verification=enforce_strict"
          "--extensions-install-verification=enforce_strict"
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

          (
            "--enable-features="
            + concatMapStrings (x: x + ",") [
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
            ]
          )

          (
            "--disable-features="
            + concatMapStrings (x: x + ",") [
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
            ]
          )
        ]
      ];
    };
  };
}
