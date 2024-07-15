{ lib, osConfig, ... }:
{
  config = lib.modules.mkIf osConfig.garden.programs.tui.enable {
    programs.btop = {
      enable = true;
      settings = {
        vim_keys = true;
        rounded_corners = true;
      };
    };
  };
}
