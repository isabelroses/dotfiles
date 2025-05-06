{ config, ... }:
{
  config.programs.lazygit = {
    inherit (config.garden.profiles.workstation) enable;

    settings = {
      update.method = "never";

      gui = {
        nerdFontsVersion = 3;
        authorColors = {
          comfysage = "#b2c98f";
          robin = "#b2c98f";
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
