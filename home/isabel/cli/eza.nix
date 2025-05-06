{ config, ... }:
{
  programs.eza = {
    inherit (config.garden.profiles.workstation) enable;
    icons = "auto";

    enableNushellIntegration = false;

    extraOptions = [
      "--group"
      "--group-directories-first"
      "--header"
      "--no-permissions"
      "--octal-permissions"
    ];
  };
}
