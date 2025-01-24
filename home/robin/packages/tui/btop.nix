{ lib, config, ... }:
{
  config = lib.modules.mkIf config.garden.programs.tui.enable {
    programs.btop = {
      enable = true;
      settings = {
        vim_keys = true;
        rounded_corners = true;
      };
    };
  };
}
