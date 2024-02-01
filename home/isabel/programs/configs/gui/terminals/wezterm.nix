{
  osConfig,
  lib,
  inputs',
  ...
}: {
  config =
    /*
    lib.mkIf osConfig.modules.programs.gui.terminals.wezterm.enable
    */
    {
      programs.wezterm = {
        enable = true;
        package = inputs'.wezterm.packages.default;
      };
    };
}
