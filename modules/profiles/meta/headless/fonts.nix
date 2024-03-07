{lib, ...}: {
  # we don't need fonts on a server
  # since there are no fonts to be configured outside the console
  fonts = let
    inherit (lib) mkForce;
  in {
    package = mkForce [];
    fontDir.enable = mkForce false;
    fontconfig.enable = mkForce false;
  };
}
