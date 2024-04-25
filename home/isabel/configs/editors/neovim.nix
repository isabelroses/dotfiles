{
  lib,
  inputs',
  osConfig,
  ...
}: let
  cfg = osConfig.modules.programs;
in {
  # need this one for uni
  home.packages = lib.optionals cfg.agnostic.editors.neovim.enable [inputs'.izvim.packages.default];
}
