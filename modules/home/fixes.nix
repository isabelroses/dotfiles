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
  home.file = mkIf (cfg != null) {
    ".icons/default/index.theme".enable = false;
    ".icons/${cfg.name}".enable = false;
  };
}
