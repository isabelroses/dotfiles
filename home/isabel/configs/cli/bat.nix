{
  lib,
  osConfig,
  ...
}: {
  programs.bat = lib.mkIf (lib.isModernShell osConfig) {
    enable = true;
  };
}
