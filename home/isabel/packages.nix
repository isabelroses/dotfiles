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
        # wishlist # fancy ssh
        glow # fancy markdown
        # fx # fancy jq
        # gum # a nicer scripting
        jq # json parser
        just # cool build tool
        nix-output-monitor # much nicer nix build output
        rsync
        unzip
        wakatime-cli
        yq # yaml parser
        # keep-sorted end
        ;

      inherit (inputs'.tgirlpkgs.packages) zzz; # code snippets in the cli
    })

    (optionalAttrs cfg.graphical.enable {
      inherit (pkgs)
        # keep-sorted start
        manga-tui # tui manga finder + reader
        # bitwarden-cli # bitwarden, my chosen password manager
        # vhs # programmatically make gifs
        # keep-sorted end
        ;
    })

    (optionalAttrs (cfg.graphical.enable && isLinux) {
      inherit (pkgs)
        # keep-sorted start
        brightnessctl # brightness managed via cli
        cliphist
        grim
        libnotify # needed for some notifications
        playerctl
        pwvucontrol
        slurp
        # bitwarden-desktop # password manager
        # jellyfin-media-player
        # insomnia # rest client
        # inkscape # vector graphics editor
        # gimp # image editor
        swappy # used for screenshot area selection
        wl-clipboard
        wl-gammactl
        # keep-sorted end
        ;

      inherit (inputs'.tgirlpkgs.packages) tidaluna;
    })
  ];
}
