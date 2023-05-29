{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.starship = {
    enable = true;
    settings = lib.importTOML ../config/starship.toml;
  };
}
