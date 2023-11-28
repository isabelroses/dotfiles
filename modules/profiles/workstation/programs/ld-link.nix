{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) optionals;
in {
  config = {
    systemd.tmpfiles.rules = optionals (!config.programs.nix-ld.dev.enable) [
      "L+ /lib64/ld-linux-x86-64.so.2 - - - - ${pkgs.glibc}/lib64/ld-linux-x86-64.so.2"
    ];
  };
}
