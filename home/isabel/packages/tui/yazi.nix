{
  lib,
  config,
  ...
}:
{
  programs.yazi = lib.modules.mkIf config.garden.programs.tui.enable {
    enable = true;
  };
}
