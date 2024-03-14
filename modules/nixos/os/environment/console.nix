{
  lib,
  pkgs,
  ...
}: {
  console = {
    enable = lib.mkDefault true;
    catppuccin.enable = true;
    earlySetup = true;

    keyMap = "en";
    font = "${pkgs.terminus_font}/share/consolefonts/ter-d18n.psf.gz";
  };
}
