{ config, ... }:
let
  inherit (config.programs) git;
in
{
  programs.jujutsu = {
    inherit (git) enable;

    settings = {
      user = {
        name = git.userName;
        email = git.userEmail;
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
