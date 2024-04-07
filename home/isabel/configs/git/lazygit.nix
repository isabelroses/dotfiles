{
  lib,
  osConfig,
  ...
}: {
  config.programs.lazygit = lib.mkIf osConfig.modules.programs.tui.enable {
    enable = true;
    catppuccin.enable = true;

    settings = {
      update.method = "never";

      gui = {
        nerdFontsVersion = 3;

        authorColors."isabel" = "#f5c2e7";
      };

      git.paging = {
        colorArg = "always";
        pager = "delta --paging=never";
      };
    };
  };
}
