{ lib, osConfig, ... }:
{
  config.programs.lazygit = lib.modules.mkIf osConfig.garden.programs.tui.enable {
    enable = true;

    settings = {
      update.method = "never";

      gui = {
        nerdFontsVersion = 3;
        authorColors = {
          comfysage = "#b2c98f";
          isabel = "#f5c2e7";
        };
      };

      git.paging = {
        colorArg = "always";
        pager = "delta --paging=never";
      };
    };
  };
}
