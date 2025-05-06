{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;

  ctp = config.catppuccin;

  configFile = "${config.xdg.configHome}/lazygit/config.yml";

  cond = config.garden.profiles.workstation.enable && config.garden.programs.git.enable;
in
{
  config = mkIf cond {
    catppuccin.lazygit.enable = false;

    home.sessionVariables = {
      # Ensure that the default config file is still sourced
      LG_CONFIG_FILE = "${ctp.sources.lazygit}/${ctp.flavor}/${ctp.accent}.yml,${configFile}";
    };

    programs.lazygit = {
      enable = true;

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
  };
}
