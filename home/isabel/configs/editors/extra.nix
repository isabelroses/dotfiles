{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  cfg = osConfig.modules.programs;
in
{
  home.packages =
    with pkgs;
    lib.optionals cfg.gui.enable [
      jetbrains.idea-ultimate # eww java
      jdk22
      # arduino # thank god I don't have to use this anymore
    ];
}
