{
  lib,
  pkgs,
  self,
  config,
  ...
}:
let
  fontdir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "${config.home.homeDirectory}/Library/Fonts"
    else
      "${config.xdg.dataHome}/fonts";
in
{
  home.activation = lib.mkIf config.garden.style.fonts.enable {
    installCustomFonts =
      lib.hm.dag.entryAfter [ "writeBoundary" ]
        # bash
        ''
          mkdir -p "${fontdir}"
          install -Dm644 ${self}/secrets/fonts/* "${fontdir}"
        '';
  };

  garden.style.fonts = {
    name = "Berkeley Mono";
    package = null;
  };
}
