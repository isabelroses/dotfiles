{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) isModernShell;

  inherit (config.programs) git;

  cond = config.garden.programs.git.enable && (isModernShell config);
in
{
  config = mkIf cond {
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
