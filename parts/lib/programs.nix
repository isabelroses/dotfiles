{ lib }:
let
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (lib.attrsets) recursiveUpdate;

  mkProgram =
    pkgs: name: extraConfig:
    recursiveUpdate {
      enable = mkEnableOption "Enable ${name}";
      package = mkPackageOption pkgs name { };
    } extraConfig;
in
{
  inherit mkProgram;
}
