{ lib, osConfig, ... }:
{
  programs.bat = lib.mkIf (lib.isModernShell osConfig) {
    # We activate it like this so that catppuccin is applied
    enable = true;
  };
}
