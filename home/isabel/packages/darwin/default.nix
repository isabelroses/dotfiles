{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    lib.mkIf stdenv.isDarwin [
      libwebp
      m-cli
      coreutils
    ];
}
