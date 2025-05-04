{
  pkgs,
  inputs',
  config,
  ...
}:
let
  ctp = config.catppuccin;

  cfg = config.garden.wrappers.lazygit;
  configFormat = pkgs.formats.yaml { };
  configFile = configFormat.generate "lazygit-config" cfg.settings;
in
{
  garden.wrappers.lazygit = {
    enable = true;
    package = pkgs.lazygit;

    env.LG_CONFIG_FILE = "${inputs'.catppuccin.packages.lazygit}/${ctp.flavor}/${ctp.accent}.yml,${configFile}";

    settings = {
      update.method = "never";

      gui = {
        nerdFontsVersion = 3;
        authorColors.isabel = "#f5c2e7";
      };

      git = {
        overrideGpg = true;
        paging = {
          colorArg = "always";
          pager = "delta --paging=never";
        };
      };
    };
  };
}
