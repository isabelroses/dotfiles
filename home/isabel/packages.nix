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
        nix-output-monitor # much nicer nix build output
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
