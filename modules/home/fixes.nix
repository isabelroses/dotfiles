{
  lib,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;

  cfg = config.home.pointerCursor;
in
{
  home.file = mkIf cfg.enable {
    ".icons/default/index.theme".enable = false;
    ".icons/${cfg.name}".enable = false;
  };
}
