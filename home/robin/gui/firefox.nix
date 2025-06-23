{ lib, config, ... }:
{
  programs.firefox.enable = lib.mkDefault (config.garden.programs.defaults.browser == "firefox");
}
