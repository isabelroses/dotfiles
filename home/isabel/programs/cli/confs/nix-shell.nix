{
  osConfig,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf osConfig.modules.programs.cli.enable {
    home.packages = with pkgs; [
      alejandra
      nix-tree
    ];
  };
}
