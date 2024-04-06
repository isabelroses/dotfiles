{
  lib,
  osConfig,
  ...
}: {
  imports = [./config.nix];
  config = lib.mkIf osConfig.modules.programs.gui.launchers.wofi.enable {
    programs.wofi.enable = true;
  };
}
