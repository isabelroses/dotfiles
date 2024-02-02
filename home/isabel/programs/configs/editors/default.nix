{
  osConfig,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./micro
    ./nvim
    ./vscode
  ];

  # need this one for uni
  config.home.packages = with pkgs;
    lib.optionals osConfig.modules.programs.gui.enable [
      jetbrains.idea-ultimate
      # arduino
    ];
}
