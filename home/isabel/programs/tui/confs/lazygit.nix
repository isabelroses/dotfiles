{
  config,
  lib,
  osConfig,
  ...
}: {
  config.programs.lazygit = lib.mkIf (osConfig.modules.usrEnv.programs.tui.enable) {
    enable = true;
    catppuccin.enable = true;
  };
}
