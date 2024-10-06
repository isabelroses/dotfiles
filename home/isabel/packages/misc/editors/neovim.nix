{
  lib,
  inputs',
  osConfig,
  ...
}:
let
  cfg = osConfig.garden.programs.neovim;
in
{
  home.packages = lib.lists.optionals cfg.enable [ inputs'.izvim.packages.default ];
}
