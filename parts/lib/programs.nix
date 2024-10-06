{ lib }:
let
  inherit (lib.options) mkEnableOption mkPackageOption mkOption;
  inherit (lib.types) either str listOf;
  inherit (lib.attrsets) recursiveUpdate;

  mkProgram =
    pkgs: name: extraConfig:
    recursiveUpdate {
      enable = mkEnableOption "Enable ${name}";
      package = mkPackageOption pkgs name { };
      args = mkOption {
        type = either str (listOf str);
        default = [ ];
      };
    } extraConfig;
in
{
  inherit mkProgram;
}
