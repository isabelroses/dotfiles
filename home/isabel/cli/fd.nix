{ config, ... }:
{
  programs.fd = {
    inherit (config.garden.profiles.workstation) enable;

    hidden = true;
    ignores = [
      ".git/"
      "*.bak"
    ];
  };
}
