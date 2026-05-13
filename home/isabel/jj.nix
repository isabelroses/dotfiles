{ config, ... }:
let
  gitcfg = config.programs.git;
in
{
  programs.jujutsu = {
    inherit (gitcfg) enable;

    settings = {
      user = {
        inherit (gitcfg.settings.user) name email;
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
