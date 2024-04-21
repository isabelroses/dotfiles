{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    lib.mkIf stdenv.isDarwin [
      webp
      m-cli
      coreutils
    ];
}
