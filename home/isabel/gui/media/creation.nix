{
  lib,
  pkgs,
  config,
  ...
}:
{
  garden.packages = lib.mkIf config.garden.profiles.media.creation.enable {
    inherit (pkgs)
      inkscape # vector graphics editor
      gimp # image editor
      ;
  };
}
