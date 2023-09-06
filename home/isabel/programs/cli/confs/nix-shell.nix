{
  osConfig,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf osConfig.modules.usrEnv.programs.cli.enable {
    home.packages = with pkgs; [
      alejandra
      nix-tree
    ];
  };
}
