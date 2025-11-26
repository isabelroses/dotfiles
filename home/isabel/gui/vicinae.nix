{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.garden.profiles.graphical.enable {
    programs.vicinae = {
      enable = true;
      systemd.enable = true;
    };
  };
}
