{ pkgs, ... }:
{
  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-d18n.psf.gz";
    keyMap = "en";
  };
}
