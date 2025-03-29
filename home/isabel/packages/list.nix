{
  lib,
  pkgs,
  self,
  self',
  config,
  osConfig,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs mergeAttrsList;
  inherit (self.lib.validators) hasProfile isWayland isModernShell;

  hasSound = (osConfig.garden.system ? sound) && osConfig.garden.system.sound.enable;

  cfg = config.garden.programs;
in
{
  garden.packages = mergeAttrsList [
    (optionalAttrs (hasProfile osConfig [ "graphical" ] && cfg.cli.enable && cfg.gui.enable) {
      inherit (pkgs)
        libnotify # needed for some notifications
        # bitwarden-cli # bitwarden, my chosen password manager
        brightnessctl # brightness managed via cli
        # vhs # programmatically make gifs
        ;
    })

    (optionalAttrs cfg.cli.enable {
      inherit (pkgs)
        unzip
        rsync
        just # cool build tool
        wakatime-cli
        nix-output-monitor # much nicer nix build output
        ;

      inherit (self'.packages) scripts;
    })

    (optionalAttrs (isModernShell config) {
      inherit (pkgs)
        jq # json parser
        yq # yaml parser
        ;
    })

    (optionalAttrs (isWayland osConfig && cfg.cli.enable && cfg.gui.enable) {
      inherit (pkgs)
        grim
        slurp
        wl-clipboard
        cliphist
        ;
    })

    (optionalAttrs cfg.gui.enable {
      # inherit (pkgs)
      #   bitwarden-desktop # password manager
      #   jellyfin-media-player
      #   mangal # tui manga finder + reader
      #   insomnia # rest client
      #   inkscape # vector graphics editor
      #   gimp # image editor
      #   ;
    })

    # if the sound option exists then continue the to check if sound.enable is true
    (optionalAttrs (cfg.gui.enable && hasSound) {
      inherit (pkgs) pwvucontrol;
    })

    (optionalAttrs (hasProfile osConfig [ "graphical" ] && isWayland osConfig) {
      inherit (pkgs)
        swappy # used for screenshot area selection
        wl-gammactl
        ;
    })
  ];
}
