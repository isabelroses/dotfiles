{ lib, osConfig, ... }:
{
  config = lib.mkIf osConfig.modules.programs.tui.enable {
    programs.btop = {
      enable = true;
      settings = {
        vim_keys = true;
        rounded_corners = true;
      };
    };
  };
}
