{
  lib,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  cfg = config.garden.programs;
in
{
  config = mkIf (cfg.cli.enable && cfg.git.enable) {
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = config.programs.git.userName;
          email = config.programs.git.userEmail;
        };

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
