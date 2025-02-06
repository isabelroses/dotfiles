{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) isModernShell;
in
{
  programs.tealdeer = mkIf (isModernShell config) {
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
