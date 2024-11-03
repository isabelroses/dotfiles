{ lib, ... }:
let
  inherit (lib.modules) mkForce;
in
{
  # we don't need fonts on a server
  # since there are no fonts to be configured outside the console
  fonts = {
    packages = mkForce [ ];
    fontDir.enable = mkForce false;
    fontconfig.enable = mkForce false;
  };
}
