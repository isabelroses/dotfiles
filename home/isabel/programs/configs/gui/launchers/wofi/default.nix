{
  config,
  lib,
  osConfig,
  ...
}: {
  imports = [./config.nix];
  config = lib.mkIf osConfig.modules.programs.launchers.wofi.enable {
    programs.wofi.enable = true;
  };
}
