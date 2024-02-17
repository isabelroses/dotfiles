{
  lib,
  pkgs,
  osConfig,
  ...
}: {
  imports = [
    ./vscode

    ./micro.nix
    ./nvim.nix
  ];

  # need this one for uni
  config.home.packages = with pkgs;
    lib.optionals osConfig.modules.programs.gui.enable [
      jetbrains.idea-ultimate
      # arduino
    ];
}
