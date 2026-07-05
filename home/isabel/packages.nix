{
  lib,
  pkgs,
  config,
  inputs',
  extpkgs,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs mergeAttrsList;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;

  cfg = config.garden.profiles;
in
{
  garden.packages = mergeAttrsList [
    (optionalAttrs cfg.workstation.enable {
      inherit (pkgs)
        # keep-sorted start
        atproto-goat # a cli tool to help me manage my PDS
        glow # fancy markdown
        # gum # a nicer scripting
        jq # json parser
        just # cool build tool
        # nix-output-monitor # much nicer nix build output
        unzip
        wakatime-cli
        yq # yaml parser
        # keep-sorted end
        ;

      inherit (extpkgs)
        lethe # a cli that tracks nixos deployments
        quoteit # the cli for my quote's service
        ;

      izvim = inputs'.izvim.packages.izvim.override {
        inherit (inputs'.izlix.packages) nil;
      };

      # nom >= 2.1.7 breaks with lix so lets just use an older version for now.
      # also add a warning to eventually force me to fix this instead of forgetting
      # <https://github.com/maralorn/nix-output-monitor/issues/230>
      nix-output-monitor =
        if lib.versionAtLeast pkgs.nix-output-monitor.version "2.1.9" then
          throw "time to update nix-output-monitor. also rember to change the shell.nix"
        else
          pkgs.nix-output-monitor.overrideAttrs (oa: {
            version = "2.1.9-unstable";
            src = pkgs.fetchFromGitHub {
              owner = "maralorn";
              repo = "nix-output-monitor";
              rev = "e22c16dab4a203a53efe311f0161e82a37e5dbf7";
              hash = "sha256-lCzWt0eafug0ZKITSxJnVLrmI4Cr22I8g4zgsetiLtc=";
            };

            propagatedBuildInputs = (oa.nix-output-monitor.propagatedBuildInputs or [ ]) ++ [
              pkgs.haskellPackages.fsnotify
              pkgs.haskellPackages.doctest-parallel
            ];
          });
    })

    # (optionalAttrs cfg.graphical.enable {
    #   inherit (pkgs)
    #     # keep-sorted start
    #     # manga-tui # tui manga finder + reader
    #     # bitwarden-cli # bitwarden, my chosen password manager
    #     # vhs # programmatically make gifs
    #     # keep-sorted end
    #     ;
    # })

    (optionalAttrs (cfg.graphical.enable && isLinux) {
      inherit (pkgs)
        # keep-sorted start
        brightnessctl # brightness managed via cli
        grim # screenshots
        libnotify # needed for some notifications
        pwvucontrol
        signal-desktop
        slurp # used for screenshot area selection
        # bitwarden-desktop # password manager
        # jellyfin-media-player
        # insomnia # rest client
        swappy # used for post screenshot editing
        wl-clipboard-rs
        wl-gammactl
        # keep-sorted end
        ;

      inherit (extpkgs) cake-wallet;
    })

    (optionalAttrs (cfg.workstation.enable && (cfg.graphical.enable || isDarwin)) {
      inherit (pkgs)
        obsidian
        pandoc
        ;
    })

    (optionalAttrs cfg.media.watching.enable {
      inherit (pkgs) ff2mpv-rust;
    })

    (optionalAttrs (cfg.media.watching.enable && isLinux) {
      inherit (pkgs)
        syncplay
        ffmpeg
        playerctl
        ;
    })

    (optionalAttrs cfg.media.creation.enable {
      inherit (pkgs)
        # inkscape # vector graphics editor
        gimp # image editor
        ;
    })
  ];
}
