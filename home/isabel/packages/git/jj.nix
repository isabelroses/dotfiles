{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;

  cfg = config.garden.programs;
  inherit (config.programs) git;
in
{
  config = mkIf cfg.git.enable {
    programs.jujutsu = {
      enable = true;

      settings = {
        user = {
          name = git.userName;
          email = git.userEmail;
        };

        git.subprocess = true;

        ui = {
          default-command = "status";
        };

        template-aliases = {
          "format_short_signature(signature)" = "signature.email().local()";
        };
      };
    };
  };
}
