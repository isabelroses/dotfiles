{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault ldTernary;
in {
  system.stateVersion = ldTernary pkgs (mkDefault "23.05") (mkDefault 4);
}
