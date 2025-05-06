{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkOption;
  inherit (self.lib) mkProgram;
in
{
  options.garden.programs = {
    git = mkProgram pkgs "git" {
      enable.default = config.garden.profiles.workstation.enable;

      package.default = pkgs.gitMinimal;

      signingKey = mkOption {
        type = lib.types.str;
        default = "";
        description = "The default gpg key used for signing commits";
      };
    };

    cocogitto = mkProgram pkgs "cocogitto" {
      enable.default = config.garden.programs.git.enable;
    };
  };
}
