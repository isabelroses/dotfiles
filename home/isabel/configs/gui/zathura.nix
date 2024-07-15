{
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  config = lib.modules.mkIf osConfig.garden.programs.gui.zathura.enable {
    xdg.configFile."zathura/catppuccin-mocha".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/catppuccin/zathura/main/src/catppuccin-mocha";
      sha256 = "0r2bgh4y7hymq8hhsjc70aw7yw85v668vgqcrcmdsggvdsk4rv1w";
    };

    programs.zathura = {
      enable = true;
      extraConfig = "include catppuccin-mocha";

      options = {
        font = "${osConfig.garden.style.font.name} 15";
        selection-clipboard = "clipboard";
        #adjust-open = "best-fit";
        #pages-per-row = "1";
        scroll-page-aware = "true";
        scroll-full-overlap = "0.01";
        scroll-step = "100";
        smooth-scroll = true;
        zoom-min = "10";
        guioptions = "none";
      };
    };
  };
}
