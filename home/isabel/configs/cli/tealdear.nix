{
  lib,
  osConfig,
  ...
}: {
  config = lib.mkIf (lib.isModernShell osConfig) {
    programs.tealdeer = {
      enable = true;
      settings = {
        display = {
          compact = false;
          use_pager = true;
        };

        updates.auto_update = false;
      };
    };
  };
}
