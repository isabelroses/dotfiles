{pkgs, ...}: {
  console = {
    # hidpi terminal font
    font = "${pkgs.terminus_font}/share/consolefonts/ter-d18n.psf.gz";
    keyMap = "en";

    # make the terminal that bit more readable
    colors = [
      "1e1e2e"
      "585b70"
      "bac2de"
      "a6adc8"
      "f38ba8"
      "f38ba8"
      "a6e3a1"
      "a6e3a1"
      "f9e2af"
      "f9e2af"
      "89b4fa"
      "89b4fa"
      "f5c2e7"
      "f5c2e7"
      "94e2d5"
      "94e2d5"
    ];
  };
}
