{
  lib,
  pkgs,
  config,
  ...
}:
{
  users.users.isabel.packages = map (lib.flip import { inherit lib pkgs config; }) [
    ./chromium.nix
  ];
}
