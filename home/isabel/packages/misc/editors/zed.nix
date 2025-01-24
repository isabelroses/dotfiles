{
  lib,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  cfg = config.garden.programs.zed;
in
{
  programs.zed-editor = mkIf cfg.enable {
    enable = true;
  };
}
