{
  lib,
  pkgs,
  config,
  inputs',
  ...
}:
let
  inherit (lib) optionalAttrs mergeAttrsList;
  inherit (pkgs.stdenv.hostPlatform) isLinux;

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
        rsync
        unzip
        wakatime-cli
        yq # yaml parser
        # keep-sorted end
        ;

      # nom >= 2.1.7 breaks with lix so lets just use an older version for now.
      # also add a warning to eventually force me to fix this instead of forgetting
      nix-output-monitor =
        if lib.versionAtLeast pkgs.nix-output-monitor.version "2.1.9" then
          throw "time to update nix-output-monitor. also rember to change the shell.nix"
        else
          pkgs.nix-output-monitor.overrideAttrs {
            version = "2.1.6";
            src = pkgs.fetchzip {
              url = "https://code.maralorn.de/maralorn/nix-output-monitor/archive/v2.1.6.tar.gz";
              sha256 = "sha256-YfxFcGD9U7RzctnTRUQX1Nsz2EtiDIUGpz2nTo0OSWw=";
            };
          };

      inherit (inputs'.extersia.packages) zzz; # code snippets in the cli
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
        grim
        libnotify # needed for some notifications
        pwvucontrol
        signal-desktop
        slurp
        # bitwarden-desktop # password manager
        # jellyfin-media-player
        # insomnia # rest client
        swappy # used for screenshot area selection
        wl-clipboard-rs
        wl-gammactl
        # keep-sorted end
        ;

      inherit (inputs'.extersia.packages) cake-wallet;
    })
  ];
}
