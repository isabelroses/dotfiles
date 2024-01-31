{
  lib,
  osConfig,
  ...
}: {
  config.programs.lazygit = lib.mkIf osConfig.modules.programs.tui.enable {
    enable = true;
    catppuccin.enable = true;
  };
}
