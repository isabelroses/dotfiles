{
  lib,
  pkgs,
  ...
}: {
  programs.direnv = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    nix-direnv.enable = true;
  };
}
