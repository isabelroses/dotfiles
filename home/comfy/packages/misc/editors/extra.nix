{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  cfg = osConfig.garden.programs;

  inherit (lib.lists) optionals;
in
{
  home.packages = optionals cfg.gui.enable [
    pkgs.jetbrains.idea-ultimate # eww java
    pkgs.jdk22
    # pkgs.arduino # thank god I don't have to use this anymore
  ];
}
