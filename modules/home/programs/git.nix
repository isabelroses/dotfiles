{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (self.lib.programs) mkProgram;
  inherit (lib.options) mkOption;
in
{
  options.garden.programs = {
    git = mkProgram pkgs "git" {
      enable.default = config.garden.programs.cli.enable;

      package.default = pkgs.gitMinimal;

      signingKey = mkOption {
        type = lib.types.str;
        default = "";
        description = "The default gpg key used for signing commits";
      };
    };
  };
}
