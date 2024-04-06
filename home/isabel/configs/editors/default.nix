{
  lib,
  pkgs,
  inputs',
  osConfig,
  ...
}: let
  inherit (lib) optionals;
  cfg = osConfig.modules.programs;
in {
  imports = [
    ./vscode

    ./micro.nix
  ];

  # need this one for uni
  config.home.packages = with pkgs;
    optionals cfg.gui.enable [
      jetbrains.idea-ultimate
      # arduino
    ]
    ++ optionals cfg.agnostic.editors.neovim.enable [inputs'.izvim.packages.default];
}
