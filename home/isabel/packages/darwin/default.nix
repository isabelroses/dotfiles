{ lib, pkgs, ... }:
{
  home.packages =
    with pkgs;
    lib.modules.mkIf stdenv.isDarwin [
      libwebp # WebP image format library
      m-cli # A macOS cli tool to manage macOS - a true swis army knife
      coreutils # GNU core utilities - the ones provided by default are bad lol
    ];
}
