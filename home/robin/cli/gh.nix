{ config, ... }:
{
  config = {
    programs.gh = {
      enable = config.garden.programs.git.enable && config.garden.profiles.workstation.enable;

      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
  };
}
