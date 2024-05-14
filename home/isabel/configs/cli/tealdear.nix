{ lib, osConfig, ... }:
{
  programs.tealdeer = lib.mkIf (lib.isModernShell osConfig) {
    enable = true;
    settings = {
      display = {
        compact = false;
        use_pager = true;
      };

      updates.auto_update = false;
    };
  };
}
