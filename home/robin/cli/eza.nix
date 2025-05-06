{ config, ... }:
{
  programs.eza = {
    inherit (config.garden.profiles.workstation) enable;
    icons = "auto";

    enableNushellIntegration = false;

    extraOptions = [
      "-l"
      "-a"
      "--group"
      "--group-directories-first"
      "--no-user"
      "--no-time"
      "--no-permissions"
      "--octal-permissions"
    ];
  };
}
