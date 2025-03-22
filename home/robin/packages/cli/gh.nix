{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) isModernShell;
  cond = config.garden.programs.git.enable && (isModernShell config);
in
{
  config = mkIf cond {
    programs.gh = {
      enable = true;

      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
  };
}
