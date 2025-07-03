{ config, ... }:
{
  config = {
    programs.gh = {
      enable = config.programs.git.enable && config.garden.profiles.workstation.enable;

      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
  };
}
