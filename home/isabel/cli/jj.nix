{ config, ... }:
let
  gitcfg = config.programs.git;
in
{
  programs.jujutsu = {
    inherit (gitcfg) enable;

    settings = {
      user = {
        name = gitcfg.settings.user.name;
        email = gitcfg.settings.user.email;
      };

      ui = {
        default-command = "status";
      };

      template-aliases = {
        "format_short_signature(signature)" = "signature.email().local()";
      };
    };
  };
}
