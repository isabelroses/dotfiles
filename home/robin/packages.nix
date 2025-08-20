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
        unzip
        rsync
        just # cool build tool
        wakatime-cli
        nix-output-monitor # much nicer nix build output
        # wishlist # fancy ssh
        glow # fancy markdown
        # fx # fancy jq
        # gum # a nicer scripting
        jq # json parser
        yq # yaml parser
        ;

      inherit (inputs'.tgirlpkgs.packages) zzz; # code snippets in the cli
    })

    (optionalAttrs cfg.graphical.enable {
      inherit (pkgs)
        # bitwarden-desktop # password manager
        # jellyfin-media-player
        # insomnia # rest client
        # inkscape # vector graphics editor
        # gimp # image editor
        manga-tui # tui manga finder + reader
        # bitwarden-cli # bitwarden, my chosen password manager
        # vhs # programmatically make gifs
        youtube-music
        ;
    })

    (optionalAttrs (cfg.graphical.enable && isLinux) {
      inherit (pkgs)
        swappy # used for screenshot area selection
        wl-gammactl
        brightnessctl # brightness managed via cli
        libnotify # needed for some notifications
        grim
        slurp
        wl-clipboard
        cliphist
        pwvucontrol
        ;
    })

    (optionalAttrs cfg.workstation.enable {
      inherit (pkgs) zig;
    })
  ];
}
